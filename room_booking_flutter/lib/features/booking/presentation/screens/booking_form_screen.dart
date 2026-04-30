import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/themes/app_theme.dart';
import '../providers/booking_provider.dart';

class BookingFormScreen extends StatefulWidget {
  final RoomModel room;
  const BookingFormScreen({super.key, required this.room});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purposeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _attendees = 1;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _agreedToPolicy = false;
  bool _isSubmitting = false;
  bool _isCheckingAvail = false;
  String? _availabilityMessage;
  bool? _isAvailable;

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);
  String get _startStr =>
      '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
  String get _endStr =>
      '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';
  String get _displayDate => DateFormat('EEEE, dd MMM yyyy').format(_selectedDate);

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() {
        _selectedDate = d;
        _isAvailable = null;
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final t = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (t != null) {
      setState(() {
        if (isStart) {
          _startTime = t;
        } else {
          _endTime = t;
        }
        _isAvailable = null;
      });
    }
  }

  Future<void> _checkAvailability() async {
    setState(() { _isCheckingAvail = true; _availabilityMessage = null; });
    final result = await context.read<BookingProvider>().checkAvailability(
        roomId: widget.room.id,
        date: _dateStr,
        startTime: _startStr,
        endTime: _endStr);
    setState(() {
      _isCheckingAvail = false;
      _isAvailable = result['available'];
      _availabilityMessage = _isAvailable == true
          ? '✓ Room is available for this time slot!'
          : '✗ Room is not available. Please choose a different time.';
    });
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToPolicy) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please agree to the room usage policy before booking.'),
        backgroundColor: AppTheme.danger,
      ));
      return;
    }
    setState(() => _isSubmitting = true);

    final result = await context.read<BookingProvider>().createBooking(
          roomId: widget.room.id,
          date: _dateStr,
          startTime: _startStr,
          endTime: _endStr,
          purpose: _purposeCtrl.text.trim(),
          attendees: _attendees,
          agreedToRoomPolicy: _agreedToPolicy,
          notes: _notesCtrl.text.trim(),
        );

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    if (result['success'] == true) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.successGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                const Text('Booking Confirmed!',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                _ConfirmRow(label: 'Room', value: widget.room.name),
                _ConfirmRow(label: 'Date', value: _displayDate),
                _ConfirmRow(label: 'Time', value: '$_startStr – $_endStr'),
                _ConfirmRow(label: 'Purpose', value: _purposeCtrl.text),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Great, Done! 🎉'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(result['error'] ?? 'Booking failed')),
        ]),
        backgroundColor: AppTheme.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Book a Room'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            // ── Room Header Card ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.meeting_room_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.room.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.room.roomNumber}  ·  Up to ${widget.room.capacity} people',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Date ──
            _FieldLabel('Select Date'),
            const SizedBox(height: 8),
            _TapField(
              icon: Icons.calendar_today_rounded,
              text: _displayDate,
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),

            // ── Time ──
            _FieldLabel('Booking Time'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TapField(
                    icon: Icons.access_time_rounded,
                    label: 'Start',
                    text: _startStr,
                    onTap: () => _pickTime(true),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded,
                    color: AppTheme.textMuted, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: _TapField(
                    icon: Icons.access_time_filled_rounded,
                    label: 'End',
                    text: _endStr,
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Check Availability ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: _isCheckingAvail
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.primary))
                    : const Icon(Icons.search_rounded, size: 18),
                label: Text(
                    _isCheckingAvail ? 'Checking...' : 'Check Availability'),
                onPressed: _isCheckingAvail ? null : _checkAvailability,
              ),
            ),

            if (_availabilityMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (_isAvailable == true ? AppTheme.success : AppTheme.danger)
                      .withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: (_isAvailable == true
                              ? AppTheme.success
                              : AppTheme.danger)
                          .withOpacity(0.3)),
                ),
                child: Text(
                  _availabilityMessage!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        _isAvailable == true ? AppTheme.success : AppTheme.danger,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // ── Attendees ──
            _FieldLabel('Number of Attendees'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: _attendees > 1 ? AppTheme.primary : AppTheme.textMuted,
                    onPressed: _attendees > 1
                        ? () => setState(() => _attendees--)
                        : null,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$_attendees',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary),
                        ),
                        Text('of ${widget.room.capacity} max',
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: _attendees < widget.room.capacity
                        ? AppTheme.primary
                        : AppTheme.textMuted,
                    onPressed: _attendees < widget.room.capacity
                        ? () => setState(() => _attendees++)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Purpose ──
            _FieldLabel('Purpose of Booking'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _purposeCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'e.g. Team meeting, Study session, Lecture...',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Purpose is required' : null,
            ),
            const SizedBox(height: 16),

            // ── Notes ──
            _FieldLabel('Additional Notes (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Any special requirements or setup needed...',
                prefixIcon: Icon(Icons.comment_outlined),
              ),
            ),
            const SizedBox(height: 28),

            // ── Policy Agreement ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToPolicy,
                    onChanged: (value) {
                      setState(() {
                        _agreedToPolicy = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'I agree to follow the room usage policy and booking rules.',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Submit ──
            SizedBox(
              height: 56,
              child: _isSubmitting
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5)),
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.event_available_rounded,
                            color: Colors.white, size: 18),
                        label: const Text(
                          'Confirm Booking',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        onPressed: _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: 0.2));
  }
}

class _TapField extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? label;
  final VoidCallback onTap;
  const _TapField(
      {required this.icon,
      required this.text,
      required this.onTap,
      this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null)
                    Text(label!,
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textMuted)),
                  Text(text,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                ],
              ),
            ),
            const Icon(Icons.edit_calendar_rounded,
                size: 14, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label, value;
  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textMuted)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }
}
