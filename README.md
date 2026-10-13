# GigFlow - Task Management App for Gig Workers

A modern, production-grade Flutter task management mobile application built for gig workers to organize shifts, deliveries, tasks, and deadlines seamlessly. Built for the **Whatbytes Flutter Developer Intern Assignment**.

---

## 📋 Assignment Requirements & Compliance Matrix

| Requirement Area | Specification | Implementation in Codebase | Status |
| :--- | :--- | :--- | :---: |
| **Authentication** | User registration and login using Firebase Authentication (email/password) | `LoginScreen`, `RegisterScreen`, and `AuthNotifier` using `firebase_auth` | ✅ **Fulfilled** |
| **Auth Error Handling** | Display appropriate error messages for invalid credentials | `_mapAuthErrorMessage` translates Firebase error codes into friendly user messages displayed in floating SnackBars; Form validation for email syntax and password length | ✅ **Fulfilled** |
| **Task CRUD** | Users should be able to create, edit, delete, and view tasks | - **Create**: `AddTaskDialog` (+ button)<br>- **View**: `HomeScreen` & `TaskDetailScreen`<br>- **Edit**: Edit button on `TaskDetailScreen`<br>- **Delete**: Swipe-to-dismiss & App Bar delete button with confirmation dialogs | ✅ **Fulfilled** |
| **Task Fields** | Title, description, due date, and priority (low, medium, high) | `Task` model includes `title`, `description`, `dueDate`, `priority` (`low`, `medium`, `high`), plus `isCompleted`, `userId`, and `categories` | ✅ **Fulfilled** |
| **Backend Storage** | Tasks should be stored on Firebase or any backend of choice | Cloud Firestore (`tasks` collection) scoped by authenticated `userId` | ✅ **Fulfilled** |
| **Status Toggle** | Mark tasks as complete / incomplete | Interactive circular toggle on task cards and detail view, with strikethrough styling and real-time Firestore synchronization | ✅ **Fulfilled** |
| **Task Filtering** | Filter tasks by priority and status (completed/incomplete) | `FilterDialog` supporting status filters (`All`, `Pending`, `Done`) and priority filters (`All`, `Low`, `Medium`, `High`), plus real-time search | ✅ **Fulfilled** |
| **Task Sorting** | Display in list format, sorted by due date (**earliest to latest**) | `TaskNotifier` automatically sorts filtered tasks by `dueDate.compareTo(...)` from earliest to latest. Home screen section headers also sort chronologically. | ✅ **Fulfilled** |
| **Local Data Storage** | Support local data storage & offline usability | Cloud Firestore offline persistence is explicitly enabled (`persistenceEnabled: true`), caching tasks locally on device; `shared_preferences` handles onboarding state | ✅ **Fulfilled** |
| **User Interface** | Clean, responsive UI with Material Design principles on iOS & Android | Material 3 theming, custom color palette, responsive padding, safe area bounds, and smooth animations | ✅ **Fulfilled** |

---

## 🛠 Tech Stack & Architecture

- **Framework**: Flutter 3 (Dart 3.7+)
- **State Management**: [Riverpod](https://riverpod.dev) (`StateNotifierProvider` pattern for decoupled, testable logic)
- **Backend & Auth**: Firebase Authentication & Cloud Firestore
- **Local Storage / Offline Cache**: Cloud Firestore Offline Persistence + `shared_preferences`
- **Design System**: Material Design 3 with custom brand theme (`AppColors`, `AppTheme`)
- **Testing**: Flutter Unit & Widget Tests (`flutter_test`)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (version >= 3.7.0)
- Android Studio / VS Code with Flutter extension
- Android device or emulator with Google Play Services

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/GhadeBhavesh/Flutter_Assignment.git
   cd Flutter_Assignment
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run unit tests**:
   ```bash
   flutter test
   ```

4. **Launch the application**:
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart         # Curated color tokens & tag palettes
│   │   └── app_theme.dart          # Material 3 typography and input styling
│   ├── utils/
│   │   └── date_utils.dart         # Date formatting & grouping utilities
│   └── widgets/
│       ├── custom_text_field.dart  # Form field with validation & icons
│       ├── primary_button.dart     # Pill button with loading spinner
│       ├── social_auth_button.dart # OAuth social auth UI triggers
│       └── task_logo.dart          # Animated app branding logo
├── models/
│   └── task_model.dart             # Task data entity, copyWith, toMap/fromMap
├── providers/
│   ├── auth_provider.dart          # Firebase Auth sign-in, sign-up, reset, sign-out
│   ├── auth_state.dart             # Sealed auth state hierarchy
│   └── task_provider.dart          # Real-time Firestore sync, search, filter & sort
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart       # User authentication screen
│   │   └── register_screen.dart    # New user registration screen
│   ├── home/
│   │   ├── home_screen.dart        # Task list, chronological groups & search
│   │   └── widgets/
│   │       ├── add_task_dialog.dart# Bottom sheet for creating & editing tasks
│   │       ├── filter_dialog.dart  # Filter modal for status & priority
│   │       └── task_card.dart      # Task list card with swipe-to-delete & completion
│   ├── onboarding/
│   │   └── onboarding_screen.dart  # 3-step carousel with skip & persistence
│   └── task/
│       └── task_detail_screen.dart # Detailed view, editing trigger, deletion
├── firebase_options.dart           # Platform Firebase options
└── main.dart                       # App entry point, offline cache setup & router
```

---

## 🧪 Testing

The test suite covers model serialization, filter operations, sorting logic, and date formatting:

```bash
flutter test
```
All unit tests pass cleanly:
- `Task model serialize toMap and deserialize fromMap correctly`
- `Task copyWith updates selected fields`
- `Tasks sort chronologically by dueDate (earliest to latest)`
- `Tasks filter by priority and status correctly`
- `formatTaskDate formats date correctly`
- `getGroupingKey groups Today and Tomorrow accurately`
