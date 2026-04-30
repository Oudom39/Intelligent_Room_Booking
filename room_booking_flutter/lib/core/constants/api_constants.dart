// ============================================================
// core/constants/api_constants.dart
// ============================================================
class ApiConstants {
  // Change this to your server IP when testing on physical device
  // Use 10.0.2.2 for Android emulator, localhost for web
  static const String baseUrl = 'http://127.0.0.1:8001';

  // Auth endpoints
  static const String login = '/accounts/api/login/';
  static const String register = '/accounts/api/register/';
  static const String logout = '/accounts/api/logout/';
  static const String profile = '/accounts/api/profile/';

  // Room endpoints
  static const String rooms = '/booking/api/rooms/';
  static const String roomSearch = '/booking/api/rooms/search/';
  static const String roomAvailability = '/booking/api/rooms/availability/';

  // Booking endpoints
  static const String bookings = '/booking/api/bookings/';
  static const String createBooking = '/booking/api/bookings/create/';
  static const String cancelBooking = '/booking/api/bookings/cancel/';
  static const String bookingRules = '/booking/api/rules/';

  // Chatbot endpoints
  static const String chat = '/chatbot/chat/';
  static const String chatHealth = '/chatbot/health/';
  static const String clearChat = '/chatbot/clear/';
  static const String confirmBooking = '/chatbot/confirm_booking/';

  // Media
  static const String mediaUrl = '/media/';
}
