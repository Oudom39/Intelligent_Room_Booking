import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../booking/presentation/screens/room_list_screen.dart';
import '../../../booking/presentation/screens/my_bookings_screen.dart';
import '../../../chatbot/presentation/screens/chat_screen.dart';
import '../../../authentication/presentation/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RoomListScreen(),
    MyBookingsScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  final _labels = ['Home', 'Rooms', 'Bookings', 'AI Chat', 'Profile'];

  final _icons = [
    Icons.home_outlined,
    Icons.meeting_room_outlined,
    Icons.event_note_outlined,
    Icons.smart_toy_outlined,
    Icons.person_outline_rounded,
  ];

  final _selectedIcons = [
    Icons.home_rounded,
    Icons.meeting_room_rounded,
    Icons.event_note_rounded,
    Icons.smart_toy_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_labels.length, (i) {
                final selected = _currentIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: selected ? 16 : 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: selected ? AppTheme.primaryGradient : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? _selectedIcons[i] : _icons[i],
                          color: selected ? Colors.white : AppTheme.textMuted,
                          size: 22,
                        ),
                        if (selected) ...[
                          const SizedBox(width: 6),
                          Text(
                            _labels[i],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
