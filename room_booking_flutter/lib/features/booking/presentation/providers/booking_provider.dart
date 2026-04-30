import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class RoomModel {
  final int id;
  final String name;
  final String roomNumber;
  final String roomType;
  final int capacity;
  final String description;
  final String equipment;
  final bool isAvailable;
  final String availabilityStatus;
  final String? imageUrl;

  RoomModel({
    required this.id,
    required this.name,
    required this.roomNumber,
    required this.roomType,
    required this.capacity,
    required this.description,
    required this.equipment,
    required this.isAvailable,
    required this.availabilityStatus,
    this.imageUrl,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      roomNumber: json['room_number'] ?? '',
      roomType: json['room_type'] ?? 'classroom',
      capacity: json['capacity'] ?? 0,
      description: json['description'] ?? '',
      equipment: json['equipment'] ?? '',
      isAvailable: json['is_available'] ?? true,
      availabilityStatus: json['availability_status'] ?? 'available',
      imageUrl: json['image'],
    );
  }

  String get roomTypeDisplay {
    switch (roomType) {
      case 'lab': return 'Laboratory';
      case 'conference': return 'Conference Room';
      case 'classroom': return 'Classroom';
      case 'auditorium': return 'Auditorium';
      default: return roomType;
    }
  }
}

class BookingModel {
  final int id;
  final String roomName;
  final String roomNumber;
  final String startTime;
  final String endTime;
  final double durationHours;
  final String purpose;
  final int attendees;
  final String status;
  final bool canCancel;
  final String createdAt;

  BookingModel({
    required this.id,
    required this.roomName,
    required this.roomNumber,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.purpose,
    required this.attendees,
    required this.status,
    required this.canCancel,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      roomName: json['room_name'] ?? '',
      roomNumber: json['room_number'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      durationHours:
          (json['duration_hours'] ?? 0.0).toDouble(),
      purpose: json['purpose'] ?? '',
      attendees: json['attendees'] ?? 1,
      status: json['status'] ?? 'pending',
      canCancel: json['can_cancel'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }

  Color get statusColor {
    switch (status) {
      case 'confirmed': return const Color(0xFF10B981);
      case 'cancelled': return const Color(0xFFEF4444);
      case 'pending': return const Color(0xFFF59E0B);
      case 'completed': return const Color(0xFF64748B);
      default: return const Color(0xFF94A3B8);
    }
  }
}

class BookingProvider extends ChangeNotifier {
  List<RoomModel> _rooms = [];
  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _pastBookings = [];
  bool _isLoading = false;
  String? _error;

  List<RoomModel> get rooms => _rooms;
  List<BookingModel> get upcomingBookings => _upcomingBookings;
  List<BookingModel> get pastBookings => _pastBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> _getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<void> fetchRooms({String? search, String? roomType}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var url = '${ApiConstants.baseUrl}${ApiConstants.rooms}';
      if (search != null && search.isNotEmpty) {
        url = '${ApiConstants.baseUrl}${ApiConstants.roomSearch}?query=$search';
      } else if (roomType != null) {
        url += '?room_type=$roomType';
      }

      final response =
          await http.get(Uri.parse(url), headers: _headers);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        _rooms = (data['rooms'] as List)
            .map((r) => RoomModel.fromJson(r))
            .toList();
      } else {
        _error = data['error'] ?? 'Failed to load rooms';
      }
    } catch (e) {
      _error = 'Network error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserBookings() async {
    final email = await _getEmail();
    if (email == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.bookings}?user_email=$email'),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _upcomingBookings = (data['upcoming_bookings'] as List)
            .map((b) => BookingModel.fromJson(b))
            .toList();
        _pastBookings = (data['past_bookings'] as List)
            .map((b) => BookingModel.fromJson(b))
            .toList();
      } else {
        _error = data['error'];
      }
    } catch (e) {
      _error = 'Network error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> createBooking({
    required int roomId,
    required String date,
    required String startTime,
    required String endTime,
    required String purpose,
    required int attendees,
    required bool agreedToRoomPolicy,
    String notes = '',
  }) async {
    final email = await _getEmail();
    if (email == null) return {'success': false, 'error': 'Not logged in'};

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createBooking}'),
        headers: _headers,
        body: jsonEncode({
          'user_email': email,
          'room_id': roomId,
          'date': date,
          'start_time': startTime,
          'end_time': endTime,
          'purpose': purpose,
          'attendees': attendees,
          'agreed_to_room_policy': agreedToRoomPolicy,
          'notes': notes,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        await fetchUserBookings();
      }
      return data;
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    final email = await _getEmail();
    if (email == null) return {'success': false, 'error': 'Not logged in'};
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cancelBooking}'),
        headers: _headers,
        body: jsonEncode({'booking_id': bookingId, 'user_email': email}),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        await fetchUserBookings();
      }
      return data;
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> checkAvailability({
    required int roomId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.roomAvailability}?room_id=$roomId&date=$date&start_time=$startTime&end_time=$endTime'),
        headers: _headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
