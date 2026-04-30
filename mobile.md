d:\Year 3\PP\Project_Year 3\
├── RoomBookingWebsite\          ← Your Django backend (existing)
└── RoomBookingMobile\            ← Your new mobile app (to create)
API Endpoints
GET /booking/api/rooms/ - List all rooms
GET /booking/api/rooms/availability/ - Check availability
GET /booking/api/rooms/search/ - Search rooms
GET /booking/api/bookings/ - List user bookings
POST /booking/api/bookings/create/ - Create booking
POST /booking/api/bookings/cancel/ - Cancel booking
GET /booking/api/rules/ - Get booking rules
Note: You will need to add authentication endpoints (Login/Register) and please check for many more api needed. 

Team Task Allocation 

Member
Focus
Tasks
 
Rith
DataBase + Backend/API + Support Members 2 with Flutter UI
- Prepare all APIs for both Student/User and Admin
- Ensure role-based responses (API returns only allowed data per account)
- Add missing APIs if needed (login/register, booking history, announcements, dashboard)
- Test APIs with existing database
Samol
Flutter UI – Student/User
- Build all Student/User screens: profile, booking, booking history,  announcements, about, service
- Implement role-based UI logic for Student/User
- Use reusable components for lists, cards, buttons
 
Tra
Flutter UI – Admin
- Build all Admin screens: dashboard, booking management, announcements, user management. 
- Implement role-based UI logic for Admin
- Use reusable components from Member 2 where possible
Dom
QA / Integration / Coordination + Support Member 3 with Flutter UI 
- Test all screens and API integration for both account types
- Track bugs, coordinate fixes
- Manage local server setup and Git workflow
- Ensure Student sees only their data and Admin sees all



Note when doing Frontend Part need to think of backend and database, API
Each member must know exactly about this mistakes:
UI Developer: Focus only on designing screens, widgets, layouts, navigation.


API Integration (if part of UI task): Only call existing backend APIs; do not create local storage as a fallback.


Backend/Database: Leave API and database logic for the backend team (if someone is tempted to “store locally”).


No local storage for main features.


Always call API for CRUD operations.


UI team handles: display data, error handling (like showing a message if API fails), user interactions, navigation.



room_booking_flutter/
├── lib/
│   ├── main.dart                          # App entry point
│   │
│   ├── core/                              # Core utilities (Team: Lead Developer)
│   │   ├── constants/
│   │   │   ├── api_constants.dart         # API endpoints, base URLs
│   │   │   ├── app_constants.dart         # App-wide constants
│   │   │   └── theme_constants.dart       # Colors, text styles
│   │   ├── network/
│   │   │   ├── api_client.dart            # HTTP client configuration
│   │   │   ├── api_interceptor.dart       # Token handling, logging
│   │   │   └── api_response.dart          # Response wrapper models
│   │   ├── storage/
│   │   │   ├── local_storage.dart         # Shared preferences wrapper
│   │   │   └── secure_storage.dart        # Secure token storage
│   │   ├── utils/
│   │   │   ├── date_formatter.dart        # Date/time utilities
│   │   │   ├── validators.dart            # Input validation
│   │   │   └── error_handler.dart         # Error handling
│   │   └── routes/
│   │       └── app_routes.dart            # Navigation routes
│   │
│   ├── features/                          # Feature modules
│   │   │
│   │   ├── authentication/                # ACCOUNTS MODULE (Team Member 1)
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── user_model.dart
│   │   │   │   │   ├── login_request.dart
│   │   │   │   │   └── register_request.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── services/
│   │   │   │       └── auth_service.dart      # API calls for login/register
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── login_screen.dart
│   │   │   │   │   ├── register_screen.dart
│   │   │   │   │   └── profile_screen.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── custom_text_field.dart
│   │   │   │   │   └── auth_button.dart
│   │   │   │   └── providers/
│   │   │   │       └── auth_provider.dart     # State management
│   │   │   └── domain/
│   │   │       └── entities/
│   │   │           └── user.dart
│   │   │
│   │   ├── booking/                       # BOOKING MODULE (Team Members 2 & 3)
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── room_model.dart
│   │   │   │   │   ├── booking_model.dart
│   │   │   │   │   └── booking_request.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── booking_repository.dart
│   │   │   │   └── services/
│   │   │   │       └── booking_service.dart   # API calls for bookings
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── room_list_screen.dart         # Team Member 2
│   │   │   │   │   ├── room_detail_screen.dart       # Team Member 2
│   │   │   │   │   ├── booking_form_screen.dart      # Team Member 3
│   │   │   │   │   ├── my_bookings_screen.dart       # Team Member 3
│   │   │   │   │   └── booking_history_screen.dart   # Team Member 3
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── room_card.dart
│   │   │   │   │   ├── booking_card.dart
│   │   │   │   │   ├── date_time_picker.dart
│   │   │   │   │   └── availability_calendar.dart
│   │   │   │   └── providers/
│   │   │   │       ├── room_provider.dart
│   │   │   │       └── booking_provider.dart
│   │   │   └── domain/
│   │   │       └── entities/
│   │   │           ├── room.dart
│   │   │           └── booking.dart
│   │   │
│   │   ├── chatbot/                       # CHATBOT MODULE (Team Member 4)
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── message_model.dart
│   │   │   │   │   ├── chat_request.dart
│   │   │   │   │   └── chat_response.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── chat_repository.dart
│   │   │   │   └── services/
│   │   │   │       └── chatbot_service.dart   # API calls to /chatbot/chat/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── chat_screen.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── message_bubble.dart
│   │   │   │   │   ├── chat_input.dart
│   │   │   │   │   └── typing_indicator.dart
│   │   │   │   └── providers/
│   │   │   │       └── chat_provider.dart
│   │   │   └── domain/
│   │   │       └── entities/
│   │   │           └── message.dart
│   │   │
│   │   ├── admin/                         # ADMIN MODULE (Team Member 5)
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── analytics_model.dart
│   │   │   │   └── services/
│   │   │   │       └── admin_service.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── admin_dashboard_screen.dart
│   │   │       │   ├── manage_rooms_screen.dart
│   │   │       │   ├── manage_bookings_screen.dart
│   │   │       │   └── analytics_screen.dart
│   │   │       └── widgets/
│   │   │           ├── stats_card.dart
│   │   │           └── admin_booking_card.dart
│   │   │
│   │   └── home/                          # HOME/NAVIGATION (Team Member 1)
│   │       └── presentation/
│   │           ├── screens/
│   │           │   └── home_screen.dart         # Bottom nav & drawer
│   │           └── widgets/
│   │               └── custom_drawer.dart
│   │
│   └── shared/                            # Shared widgets (All team members can contribute)
│       ├── widgets/
│       │   ├── custom_app_bar.dart
│       │   ├── loading_indicator.dart
│       │   ├── error_widget.dart
│       │   └── empty_state.dart
│       └── themes/
│           └── app_theme.dart
│
├── assets/                                # Assets (Designer/all)
│   ├── images/
│   │   ├── logo.png
│   │   └── placeholder_room.png
│   ├── icons/
│   └── fonts/
│
├── test/                                  # Unit tests (Each member tests their module)
│   ├── authentication_test.dart
│   ├── booking_test.dart
│   └── chatbot_test.dart
│
├── android/                               # Android configuration
├── ios/                                   # iOS configuration
├── pubspec.yaml                           # Dependencies
└── README.md

