# Medicine Reminder App

A Flutter-based mobile application designed to help users manage their daily medication schedule through timely notifications and an intuitive interface.

## Overview

Medicine Reminder is a fully offline Android application that enables users to schedule and track their daily medicines. The app leverages Android's native notification system to deliver reliable reminders, ensuring users never miss their medication schedule.

## Key Features

- **Medicine Management**: Add, view, and delete medicines with customizable names, dosages, and reminder times
- **Custom Scheduling**: Support for daily reminders or specific days of the week
- **Date Range Support**: Set start dates and optional end dates for medication courses
- **Daily Notifications**: Automatic recurring notifications at user-specified times
- **Notification History**: Track past medication reminders with a persistent local history
- **Notes Feature**: Add optional notes for each medicine (e.g., "Take after dinner")
- **Timezone-Aware Scheduling**: Intelligent scheduling that adapts to device timezone
- **Permission Handling**: Seamless integration with Android 12+ exact alarm permissions and Android 13+ notification permissions
- **Offline-First**: All data stored locally with no internet connection required
- **Background Reliability**: Notifications work even when the app is closed or device is locked

## Screenshots

### Add Medicine Screen
<img src="screenshots/ss3.jpg" width="300" alt="Add Medicine - Top Section">

*Add medicine with name, dose, time, and date range*

<img src="screenshots/ss1.jpg" width="300" alt="Add Medicine - Frequency Selection">

*Select frequency (Daily or Specific Days) and choose days of the week*

### Home Screen
<img src="screenshots/ss2.jpg" width="300" alt="Medicine List">

*View all scheduled medicines with their details*

## Tech Stack

### Framework & Language
- **Flutter** (Dart) - Cross-platform mobile development framework

### Architecture & Patterns
- **Clean Architecture** - Separation of data, domain, and presentation layers
- **Riverpod** - Modern state management solution for Flutter

### Data & Storage
- **Hive** - Fast, lightweight NoSQL database for local data persistence
- **Shared Preferences** - User settings and app configuration

### Notifications
- **flutter_local_notifications** - Native notification scheduling
- **timezone** - Accurate time zone handling for cross-region reliability
- **permission_handler** - Runtime permission management

### UI/UX
- **Material Design 3** - Modern, accessible design system
- **google_fonts** - Custom typography (Poppins)
- **intl** - Date and time formatting

## Architecture

The application follows **Clean Architecture** principles with clear separation of concerns:
```
lib/
├── core/
│   ├── theme/          # App-wide theming
│   └── utils/          # Notification service, helpers
├── data/
│   ├── models/         # Hive models (Medicine, NotificationHistory)
│   └── repositories/   # Data access layer
├── presentation/
│   ├── providers/      # Riverpod state management
│   ├── screens/        # UI screens
│   └── widgets/        # Reusable components
└── app.dart            # Root app configuration
```

### Key Architectural Decisions

1. **Repository Pattern**: Data access abstracted through repository classes, enabling easy testing and future backend integration
2. **Provider-Based State**: Riverpod providers manage app state reactively, ensuring UI updates automatically when data changes
3. **Service Layer**: Notification logic encapsulated in a dedicated service for maintainability
4. **Type-Safe Models**: Hive type adapters ensure compile-time safety for database operations

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter plugins
- Android device or emulator (API level 21+)

### Installation

1. **Clone the repository**
```bash
   git clone https://github.com/yourusername/medicine-reminder-app.git
   cd medicine-reminder-app
```

2. **Install dependencies**
```bash
   flutter pub get
```

3. **Generate Hive adapters**
```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. **Run the app**
```bash
   flutter run
```

### Build APK

To build a release APK:
```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

## Permissions

The app requires the following Android permissions:

| Permission | Purpose |
|------------|---------|
| `POST_NOTIFICATIONS` | Display notification reminders (Android 13+) |
| `SCHEDULE_EXACT_ALARM` | Schedule precise notification times (Android 12+) |
| `USE_EXACT_ALARM` | Alternative exact alarm permission |
| `VIBRATE` | Vibrate device on notification |
| `RECEIVE_BOOT_COMPLETED` | Restore scheduled notifications after device restart |
| `WAKE_LOCK` | Wake device to show critical medication reminders |

All permissions are requested at runtime with clear user consent flows.

## Testing

The application has been tested on:
- Real Android devices (Android 12, 13, 14)
- Various screen sizes and densities
- Different timezone configurations
- Background notification delivery scenarios

## Known Limitations

- Currently supports Android only (iOS support planned for future release)
- No medication adherence analytics or reports
- Single user support (no multi-profile functionality)

## Future Enhancements

- Medication adherence statistics and insights
- Custom notification sounds
- Integration with health platforms
- iOS support
- Multi-user support with profiles

## Learning Outcomes

This project demonstrates proficiency in:

- Building production-ready Flutter applications with clean architecture
- Implementing complex notification systems with Android-specific APIs
- Managing app state with modern reactive patterns (Riverpod)
- Handling local data persistence with NoSQL databases
- Writing maintainable, scalable code following SOLID principles
- Managing Android runtime permissions and platform-specific features
- Creating intuitive UI/UX with Material Design guidelines

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact:

For questions or feedback, please reach out via [LinkedIn](https://www.linkedin.com/in/priyanshi-srivastava8119/) or [Email](mailto:srivastavapriyanshi8081@gmail.com).

---

**Built with Flutter** 💙
```






