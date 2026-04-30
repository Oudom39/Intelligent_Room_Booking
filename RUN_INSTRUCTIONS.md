# 🚀 Running the Intelligent Room Booking System

This guide explains how to start both the **Django Backend** and the **Flutter Mobile Application**.

## 1. Prerequisites
Ensure you have the following installed on your system:
*   **Python 3.10+**
*   **Flutter SDK** (Stable channel)
*   **Git**

---

## 2. Running the Django Backend

The backend handles the database, business logic, and the AI chatbot API.

### Step 1: Activate Virtual Environment
Open a terminal in the project root (`Intelligent_Room_Booking`) and run:
```powershell
.\venv\Scripts\activate
```

### Step 2: Install Dependencies
(If not already done)
```powershell
pip install -r requirements.txt
```

### Step 3: Run the Server
Start the development server on port **8001**:
```powershell
python manage.py runserver 8001
```
> **Note**: The server must be running for the Mobile App to fetch data and log in.

---

## 3. Running the Flutter Mobile App

The mobile app provides a premium user experience for room booking and AI chat.

### Step 1: Navigate to Flutter Directory
Open a **new** terminal (keep the backend running) and go to:
```powershell
cd room_booking_flutter
```

### Step 2: Get Dependencies
```powershell
flutter pub get
```

### Step 3: Launch the App
You can run the app on Windows or Chrome:

**For Windows Desktop:**
```powershell
flutter run -d windows
```

**For Web (Chrome):**
```powershell
flutter run -d chrome
```

---

## 4. Test Credentials

Use these credentials to log in and test all features:

| Account Type | Email | Password |
| :--- | :--- | :--- |
| **Administrator** | `admin@example.com` | `password123` |
| **Lecturer/User** | `lecturer@example.com` | `password123` |

> **Important**: When logging in via the **Website**, ensure you select the correct **Account Type** (Administrator or User) from the dropdown.

---

## 5. Troubleshooting

*   **Connection Error on Mobile**: If the mobile app cannot connect to the backend, check `lib/core/constants/api_constants.dart`.
    *   For **Chrome/Windows**: Use `http://127.0.0.1:8001`
    *   For **Android Emulator**: Use `http://10.0.2.2:8001`
*   **Database Issues**: If you see "Table not found" errors, run:
    ```powershell
    python manage.py migrate
    ```
