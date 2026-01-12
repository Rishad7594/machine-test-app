# Machine Test App

Flutter application built for machine test submission.

This app demonstrates **Firebase Email & Password authentication** using **BLoC architecture**, followed by a **product listing screen with pull-to-refresh**.

---

## 🔐 Authentication Flow (Important)

1. **Create Account**
   - Open the app
   - Click **Create Account**
   - Register using Email & Password

2. **Login**
   - After successful signup, log in using the **same credentials**
   - On successful login, user is redirected to the **Products screen**

3. **Logout**
   - User can log out from the Products screen

> ⚠️ Account must be created first before login.

---

## ✨ Features
- Firebase Email & Password Authentication (REST)
- BLoC state management
- Product listing with pull-to-refresh
- Clean and responsive UI
- Works on Android, Web, and Desktop

---

## 🛠 Tech Stack
- Flutter
- flutter_bloc
- Firebase Authentication (REST API)

---

## ▶️ How to Run the App

### Step 1: Clean project
```bash
flutter clean

## Step 2: Get dependencies
flutter pub get

## Step 3: Run the app
flutter run

📱 Build APK (Recommended)

## Mobile UI provides a better user experience.

Build release APK
flutter clean
flutter pub get
flutter build apk --release


APK will be generated at:

build/app/outputs/flutter-apk/app-release.apk
