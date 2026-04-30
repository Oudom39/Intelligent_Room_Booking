import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'shared/themes/app_theme.dart';
import 'features/authentication/presentation/providers/auth_provider.dart';
import 'features/authentication/presentation/screens/login_screen.dart';
import 'features/booking/presentation/providers/booking_provider.dart';
import 'features/chatbot/presentation/providers/chat_provider.dart';
import 'features/home/presentation/screens/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const RoomBookingApp());
}

class RoomBookingApp extends StatelessWidget {
  const RoomBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Room Booking',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AppRoot(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const MainNavigation(),
          '/rooms': (_) => const MainNavigation(),
          '/bookings': (_) => const MainNavigation(),
          '/chat': (_) => const MainNavigation(),
          '/profile': (_) => const MainNavigation(),
        },
      ),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn =
        await context.read<AuthProvider>().checkAuthenticated();
    if (!mounted) return;
    setState(() => _checking = false);
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primary,
                child: Icon(Icons.meeting_room_rounded,
                    color: Colors.white, size: 36),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: AppTheme.primary),
            ],
          ),
        ),
      );
    }
    return const LoginScreen();
  }
}
