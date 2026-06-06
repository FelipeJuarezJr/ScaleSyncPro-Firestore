# RepFiles - Reptile Management System

A Flutter application for managing reptile collections, breeding projects, schedules, and inventory. Built with the same beautiful design as the original HTML version.

## 🔗 **Important: ReptiGram Integration**

**RepFiles connects to ReptiGram's Firebase project** for authentication. This means:
- ✅ **Same login credentials** - Users can log into RepFiles with the same email/password they use for ReptiGram
- ✅ **Shared user accounts** - No need to create separate accounts
- ✅ **Read-only access** - RepFiles cannot modify ReptiGram's data, only authenticate users
- 🔒 **Secure integration** - Uses ReptiGram's existing Firebase authentication system

## ✨ Features

- 🎨 **Beautiful UI** - Matches the original HTML design exactly
- 🌙 **Dark Theme** - Nocturnal mode with bright green accents
- 📱 **Responsive Design** - Works on desktop, tablet, and mobile
- 🔐 **Authentication** - Login with ReptiGram credentials
- 📊 **Dashboard** - Statistics, charts, and activity feed
- 🦎 **Reptile Management** - Track your reptile collection
- 🧬 **Breeding Projects** - Manage breeding programs
- 📅 **Schedule Management** - Task and feeding schedules
- 📦 **Inventory Tracking** - Food and supplies management
- 📈 **Reports & Analytics** - Data visualization and insights

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Chrome browser (for web development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd RepFilesFirestore
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - ✅ **Already configured** - Uses ReptiGram's Firebase project
   - 🔑 **Authentication** - Works with existing ReptiGram user accounts
   - 📊 **Firestore** - Connected to ReptiGram's database

4. **Run the application**
   ```bash
   # For web
   flutter run -d chrome
   
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   ```

## 🎨 Design System

### Color Palette (Dark Theme)
- **Primary**: `#00FF00` (Bright Green)
- **Primary Light**: `#00D4FF` (Cyan)
- **Secondary**: `#00FF00` (Green)
- **Accent**: `#FFA500` (Orange)
- **Success**: `#00FF00` (Green)
- **Warning**: `#FFA500` (Orange)
- **Danger**: `#FF0000` (Red)
- **Info**: `#00D4FF` (Cyan)

### Background Colors
- **Primary**: `#1A1A1A`
- **Secondary**: `#2C2C2C`
- **Tertiary**: `#3A3A3A`

### Text Colors
- **Primary**: `#FFFFFF`
- **Secondary**: `#CCCCCC`
- **Light**: `#999999`

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # ReptiGram Firebase config
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard_screen.dart
│   ├── reptiles_screen.dart
│   ├── breeding_screen.dart
│   ├── schedule_screen.dart
│   ├── inventory_screen.dart
│   ├── reports_screen.dart
│   └── main_app_screen.dart
├── services/
│   ├── auth_service.dart
│   ├── theme_service.dart
│   └── reptile_service.dart
├── models/
│   └── reptile.dart
├── widgets/
│   ├── stat_card.dart
│   ├── activity_item.dart
│   └── quick_action_button.dart
└── utils/
    └── theme.dart
```

## 🔧 Dependencies

### Core
- `flutter` - Flutter framework
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication (ReptiGram integration)
- `cloud_firestore` - Database operations
- `firebase_storage` - File storage

### UI & Charts
- `fl_chart` - Data visualization
- `qr_flutter` - QR code generation
- `image_picker` - Image selection

### State Management
- `provider` - State management
- `shared_preferences` - Local storage
- `intl` - Internationalization

## 🏗️ Building

### Web Build
```bash
flutter build web
```

### Android Build
```bash
flutter build apk
```

### iOS Build
```bash
flutter build ios
```

## 🔐 Authentication Flow

1. **User opens RepFiles**
2. **Login screen** - Beautiful gradient background
3. **Enter credentials** - Same as ReptiGram account
4. **Authentication** - Validated against ReptiGram's Firebase
5. **Access granted** - User can use RepFiles with their existing account

## 🎯 Development Status

- ✅ **Authentication** - Connected to ReptiGram Firebase
- ✅ **UI Design** - Matches original HTML exactly
- ✅ **Theme System** - Dark/light mode support
- ✅ **Dashboard** - Statistics and charts
- 🚧 **Reptile Management** - In development
- 🚧 **Breeding Projects** - In development
- 🚧 **Schedule System** - In development
- 🚧 **Inventory** - In development
- 🚧 **Reports** - In development

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🔗 Related Projects

- **ReptiGram** - The main reptile social media platform
- **RepFiles** - This reptile management system (connects to ReptiGram)

---

**Note**: RepFiles is designed to work alongside ReptiGram, providing additional management tools while using the same user authentication system. 