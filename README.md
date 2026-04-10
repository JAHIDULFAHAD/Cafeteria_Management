# 🍽️ Rukin Cafeteria

A comprehensive **Flutter-based cafeteria management system** with real-time financial tracking, inventory management, and staff administration powered by Firebase.

## 📋 Table of Contents

- [Features](#features)
- [Project Structure](#project-structure)
- [Technologies Used](#technologies-used)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Running the Application](#running-the-application)
- [Firebase Configuration](#firebase-configuration)
- [Project Architecture](#project-architecture)
- [Data Models](#data-models)
- [Key Modules](#key-modules)
- [Development](#development)
- [Troubleshooting](#troubleshooting)

## ✨ Features

### Core Functionality

- **📊 Dashboard**
  - Real-time net cash tracking (daily & monthly)
  - Monthly sales and purchase summaries
  - Quick access to key management functions
  - Summary cards with trends and analytics

- **💰 Sales Management**
  - Record and track sales transactions
  - Net cash calculations
  - Sales history and summaries
  - Daily and monthly reporting

- **📦 Purchase Management**
  - Manage purchase orders
  - Monthly purchase tracking
  - Inventory management
  - Purchase history

- **💸 Expense Tracking**
  - Record business expenses
  - Expense categorization
  - Monthly expense reports
  - Financial overview

- **🍽️ Meal Management**
  - Track meal entries
  - Manage daily meal records
  - Meal history and summaries
  - Daily meal reporting

- **👥 Staff Management**
  - Staff administration
  - Staff records management
  - User and staff assignment

- **🔐 User Authentication**
  - Secure login and signup
  - Email verification
  - Password recovery
  - Profile management
  - User data management

### Additional Features

- ✅ Email validation
- 📱 Responsive Material Design UI
- 🎨 Green-themed professional interface
- ⚡ Real-time Firebase data synchronization
- 🔔 Toast notifications for user feedback
- 🎭 Loading animations with shimmer effects
- 📲 Native app icons for Android & iOS

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point & Firebase initialization
├── app.dart                  # Main app configuration & routing
├── firebase_options.dart     # Firebase configuration
├── Data/
│   └── Model/               # Data models
│       ├── sell_model.dart
│       ├── purchase_model.dart
│       ├── expense_model.dart
│       ├── meal_model.dart
│       ├── item_model.dart
│       ├── staff_model.dart
│       ├── user_model.dart
│       ├── dashboard_model.dart
│       ├── monthly_purchase_model.dart
│       └── dailyitem_model.dart
│
└── features/
    ├── auth/                # Authentication & User Management
    │   └── presentation/
    │       ├── screens/
    │       └── data/
    │
    ├── dashboard/           # Dashboard & Analytics
    │   └── presentation/
    │
    ├── sell/                # Sales Management
    │   └── presentation/
    │
    ├── purchase/            # Purchase Management
    │   └── presentation/
    │
    ├── expense/             # Expense Tracking
    │   └── presentation/
    │
    ├── meal/                # Meal Management
    │   └── presentation/
    │
    ├── staff/               # Staff Management
    │   └── presentation/
    │
    ├── home/                # Home Navigation Hub
    │   └── presentation/
    │
    ├── Provider/            # State Management Providers
    │   └── navigation_provider.dart
    │
    └── Widget/              # Reusable UI Widgets
        ├── appbar_widget.dart
        ├── build_summarycard.dart
        ├── full_page_loader_widget.dart
        └── ...other widgets

functions/                   # Firebase Cloud Functions
├── index.js               # User deletion & management functions
└── package.json
```

## 🛠️ Technologies Used

### Frontend
- **Flutter** (3.8.1+) - UI framework
- **Dart** - Programming language
- **Provider** (^5.0.0) - State management
- **Material Design** - UI design system

### Backend & Services
- **Firebase Core** (^4.2.1) - Firebase initialization
- **Cloud Firestore** (^6.1.0) - NoSQL database
- **Firebase Auth** (^6.1.2) - User authentication
- **Cloud Functions** (^6.0.4) - Serverless backend logic

### Utilities
- **Email Validator** (^2.1.17) - Email validation
- **Intl** (^0.18.1) - Internationalization
- **Shimmer** (^3.0.0) - Loading animations
- **FlutterToast** (^8.2.4) - Notifications
- **Collection** (^1.17.0) - Collections utilities

### Development
- **flutter_lints** (^5.0.0) - Code quality
- **flutter_test** - Testing framework
- **flutter_launcher_icons** (^0.14.4) - App icon generation

## 📱 Prerequisites

Before you begin, ensure you have:

- **Flutter SDK** (3.8.1 or higher)
  - [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **Xcode** for mobile development
- **Firebase Project** with:
  - Firestore database
  - Firebase Authentication enabled
  - Cloud Functions deployed
- **Git** for version control
- **Node.js 24+** for Firebase Functions deployment

## 🚀 Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/rukin_cafeteria.git
cd rukin_cafeteria
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

#### Option A: Using Firebase CLI (Recommended)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase project
firebase init

# Deploy Cloud Functions
cd functions
npm install
firebase deploy --only functions
```

#### Option B: Manual Configuration

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Firestore Database
3. Enable Firebase Authentication (Email/Password)
4. Add Android and iOS apps to your Firebase project
5. Download `google-services.json` and place it in `android/app/`
6. Update iOS config in Xcode (Runner project)

### 4. Generate App Icons

```bash
flutter pub run flutter_launcher_icons
```

### 5. Build & Run

```bash
# For Android
flutter run -d <device_id>

# For iOS (macOS only)
flutter run -d
```

## 🏃 Running the Application

### Development Mode

```bash
flutter run
```

### Release Build

#### Android
```bash
flutter build apk --release
# Output: build/app/release/app-release.apk
```

#### iOS
```bash
flutter build ios --release
```

### Web (if enabled)
```bash
flutter run -d chrome
```

## 🔥 Firebase Configuration

### Firestore Collections Structure

```
users/
  {uid}/
    - name
    - email
    - role
    - createdAt

sells/
  - amount
  - date
  - items
  - cashFlow

purchases/
  - items
  - amount
  - date
  - supplier

expenses/
  - category
  - amount
  - date
  - description

meals/
  - date
  - count
  - type

staff/
  - name
  - role
  - email
  - joinDate
```

### Cloud Functions

The project includes Cloud Functions for:

- **User Deletion** (`deleteUser`) - Securely removes user from Auth and Firestore

Deploy functions:
```bash
cd functions
firebase deploy --only functions
```

View logs:
```bash
firebase functions:log
```

## 🏗️ Project Architecture

### Architecture Pattern: Feature-Based (Clean Architecture)

```
Feature Structure:
feature/
├── presentation/
│   ├── screens/        # UI Pages
│   ├── widgets/        # Feature-specific widgets
│   └── data/           # Controllers/Providers
└── domain/             # Business logic (if applicable)
```

### State Management (Provider Pattern)

The app uses **Provider** for state management with multiple providers:

- `DashboardProvider` - Dashboard data and calculations
- `SellProvider` - Sales management
- `PurchaseProvider` - Purchase management
- `ExpenseProvider` - Expense tracking
- `MealProvider` - Meal data
- `StaffProvider` - Staff management
- `UserProvider` - User authentication state
- `NavigationProvider` - Bottom navigation state
- `ItemProvider` - Item management

## 📊 Data Models

### Core Models

| Model | Purpose |
|-------|---------|
| `UserModel` | User profile and authentication data |
| `SellModel` | Sales transactions |
| `PurchaseModel` | Purchase orders |
| `ExpenseModel` | Expense entries |
| `MealModel` | Meal records |
| `StaffModel` | Staff information |
| `ItemModel` | Inventory items |
| `DashboardModel` | Dashboard aggregated data |
| `MonthlyPurchaseModel` | Monthly purchase summaries |
| `DailyItemModel` | Daily item tracking |

## 🎯 Key Modules

### 1. Authentication (`features/auth/`)
- Login with email/password
- User signup with validation
- Email verification
- Password recovery
- Profile management
- User account settings

### 2. Dashboard (`features/dashboard/`)
- Real-time financial summary
- Net cash calculations
- Quick action buttons
- Summary cards with icons
- Navigation to detail screens

### 3. Sales (`features/sell/`)
- Record sales transactions
- Net cash tracking
- Sales summary views
- Daily/Monthly reporting

### 4. Purchases (`features/purchase/`)
- Manage purchase orders
- Item selection
- Monthly purchase aggregation
- Purchase history

### 5. Expenses (`features/expense/`)
- Track business expenses
- Expense categorization
- Monthly expense summary
- Detailed expense records

### 6. Meals (`features/meal/`)
- Log daily meals
- Meal type tracking
- Meal history
- Daily meal summary

### 7. Staff (`features/staff/`)
- Manage staff records
- Staff assignment
- Staff history
- User-staff relationships

## 💻 Development

### Project Setup for Development

```bash
# Get packages
flutter pub get

# Check for issues
flutter analyze

# Run tests
flutter test

# Format code
dart format lib/

# Get test coverage
flutter test --coverage
```

### Code Quality

```bash
# Lint code
dart analyze lib/

# Fix issues automatically
dart fix --apply lib/
```

### Hot Reload

During development, use hot reload for faster iterations:

```bash
flutter run
# Press 'r' for hot reload
# Press 'R' for hot restart
# Press 'q' to quit
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Firebase Initialization Error
```
Error: FirebaseCore not initialized
```
**Solution:** Ensure `Firebase.initializeApp()` is called in `main()` with `WidgetsFlutterBinding.ensureInitialized()`

#### 2. Firestore Permissions Denied
```
Error: Missing required permissions
```
**Solution:** Check Firebase Firestore security rules. For development, update rules:
```firestore
match /{document=**} {
  allow read, write: if request.auth != null;
}
```

#### 3. Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

#### 4. Android Build Errors
```bash
# Update Gradle
cd android
./gradlew --version

# Run with verbose output
flutter run -v
```

#### 5. iOS Build Issues
```bash
# Clean and update
cd ios
rm -rf Pods
rm Podfile.lock
cd ..
flutter clean
flutter pub get
flutter run
```

### Debug Mode

Run with verbose logging:

```bash
flutter run -v
```

Check real-time logs:

```bash
flutter logs
```

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package Documentation](https://pub.dev/packages/provider)
- [Flutter Material Design](https://material.io/design)
- [Cloud Functions Documentation](https://firebase.google.com/docs/functions)

## 🤝 Contributing

1. Create a feature branch
   ```bash
   git checkout -b feature/your-feature
   ```
2. Commit your changes
   ```bash
   git commit -m 'Add your feature'
   ```
3. Push to the branch
   ```bash
   git push origin feature/your-feature
   ```
4. Submit a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing issues first
- Provide detailed error messages and steps to reproduce

## 🎉 Acknowledgments

- Flutter community and documentation
- Firebase for backend services
- Provider package for state management
samples, guidance on mobile development, and a full API reference.
