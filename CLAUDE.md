# Smart Home App (smart_curtain_app)

## Overview
Flutter mobile app for smart home control - manage IoT devices (curtains, etc.) and automation scenes. Connects to ThingsBoard backend via REST API.

## Tech Stack
- **Framework:** Flutter (Dart SDK ^3.9.2)
- **State Management:** flutter_bloc (BLoC pattern)
- **DI:** get_it
- **HTTP:** dio (ApiClient with interceptors) + http package (for device/scene data sources)
- **Auth:** JWT tokens stored in flutter_secure_storage, managed by TokenManager
- **Architecture:** Clean Architecture (data -> domain -> presentation)

## Project Structure
```
lib/
├── core/
│   ├── auth/token_manager.dart    # Token cache + secure storage
│   ├── base/bloc_observer.dart    # BLoC observer
│   ├── di/injector.dart           # GetIt dependency injection setup
│   ├── error/                     # Failure/Exception classes (Equatable)
│   ├── init/                      # App initialization
│   └── network/api_client.dart    # Dio-based HTTP client with auth interceptor
├── features/
│   ├── auth/                      # Login, JWT auth (ThingsBoard)
│   ├── device/                    # Device management & control (CRUD + commands)
│   ├── home/                      # Home page, tabs, scene creation UI, BLE device setup
│   └── scene/                     # Smart scenes/automation (schedule-based)
├── main.dart                      # App entry point, MultiBlocProvider setup
└── smart_splash.dart              # Splash screen with animations
```

## Architecture Pattern (Clean Architecture per feature)
Each feature follows:
```
feature/
├── data/
│   ├── datasources/       # Remote data sources (API calls)
│   ├── models/             # Data models (fromJson/toJson)
│   └── repositories/       # Repository implementations
├── domain/
│   ├── entities/           # Business entities (Equatable)
│   ├── repositories/       # Repository interfaces (abstract)
│   └── usecases/           # Use cases
└── presentation/
    ├── bloc/               # BLoC, Events, States
    └── pages/              # UI widgets/pages
```

## Key Features
- **Auth:** Login via ThingsBoard API, token auto-injection via Dio interceptor (X-Authorization header)
- **Device:** List customer devices, delete device, send commands (on/off/open/close)
- **Scene:** Schedule-based automation (once/daily/weekly), create/delete/toggle scenes
- **BLE:** Bluetooth device discovery and WiFi configuration for new devices

## Backend
- **ThingsBoard API:** `https://performentmarketing.ddnsgeek.com`
- **Scheduler API:** `http://1.55.30.61:8000` (for scene/automation scheduling)
- Auth header: `X-Authorization: Bearer <token>`

## Commands
```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter analyze          # Static analysis
flutter test             # Run tests
flutter build apk        # Build Android APK
flutter build ios        # Build iOS
```

## Project Conventions
- Language: Vietnamese used in UI text and code comments
- Naming: snake_case for files, PascalCase for classes, camelCase for members
- Error handling: dartz Either<Failure, T> pattern in repositories
- BLoC naming: {Feature}Bloc, {Feature}Event, {Feature}State
- All BLoCs registered as Factory in GetIt, services as LazySingleton

---

# Flutter & Dart Development Rules

## Code Quality
- Apply SOLID principles throughout the codebase
- Write concise, modern Dart code. Prefer functional and declarative patterns
- Favor composition over inheritance for building complex widgets and logic
- Prefer immutable data structures. Widgets (especially StatelessWidget) should be immutable
- Functions should be short (<20 lines) and single-purpose
- Use `dart:developer` `log` instead of `print` for logging
- Use `const` constructors everywhere possible to reduce rebuilds

## Dart Best Practices
- Write sound null-safe code. Avoid `!` operator unless guaranteed non-null
- Use `Future`, `async`, `await` for async operations. Use `Stream` for events
- Use switch expressions and pattern matching where appropriate
- Use records for multiple return values
- Use custom exceptions for specific error situations
- Use `=>` arrow functions for one-line functions

## Flutter Widget Best Practices
- Compose smaller private widgets (`class MyWidget extends StatelessWidget`) over helper methods
- Use `ListView.builder` or `SliverList` for long lists (performance)
- Use `compute()` or Isolates for expensive calculations to avoid UI blocking
- Never do expensive operations (network calls) in `build()` methods
- Rebuild widgets, don't mutate them

## State Management (BLoC - This Project)
- This project uses flutter_bloc for state management
- Each feature has its own BLoC with separate Event and State classes
- Use Equatable for States and Events for proper comparison
- Emit new states instead of mutating existing ones
- Handle loading, success, and error states explicitly

## Visual Design & Theming
- Build beautiful and intuitive UIs following Material Design guidelines
- Use proper typography hierarchy (hero text, section headlines)
- Use multi-layered shadows for depth (cards should look "lifted")
- Incorporate icons to enhance navigation and understanding
- Support both light and dark themes when possible
- Use `ColorScheme.fromSeed` for harmonious color palettes

## Layout Best Practices
- Use `Expanded` to fill remaining space, `Flexible` to shrink-to-fit
- Don't combine `Flexible` and `Expanded` in the same Row/Column
- Use `Wrap` for widgets that would overflow a Row/Column
- Use `ListView.builder` / `GridView.builder` for long lists/grids
- Use `LayoutBuilder` for responsive layouts based on available space
- Handle image loading with `errorBuilder` and `loadingBuilder`

```dart
Image.network(
  'https://example.com/img.png',
  errorBuilder: (ctx, err, stack) => const Icon(Icons.error),
  loadingBuilder: (ctx, child, prog) =>
      prog == null ? child : const CircularProgressIndicator(),
);
```

## Error Handling Pattern (This Project)
```dart
// Use dartz Either for repository results
Future<Either<Failure, T>> methodName() async {
  try {
    final result = await remoteDataSource.getData();
    return Right(result);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message, message: e.message));
  }
}
```

## BLoC Pattern (This Project)
```dart
// Event
abstract class FeatureEvent extends Equatable {}
class LoadDataEvent extends FeatureEvent { ... }

// State
abstract class FeatureState extends Equatable {}
class FeatureLoading extends FeatureState {}
class FeatureLoaded extends FeatureState { final List<Entity> items; ... }
class FeatureError extends FeatureState { final String message; ... }

// BLoC
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  FeatureBloc({required this.useCase}) : super(FeatureInitial()) {
    on<LoadDataEvent>(_onLoadData);
  }
}
```

## Testing
- Write unit tests for use cases and BLoC logic
- Write widget tests for UI components
- Follow Arrange-Act-Assert pattern
- Test loading, success, and error states for each BLoC

## Accessibility
- Ensure text has contrast ratio of at least 4.5:1 against background
- Test UI with increased system font sizes
- Use `Semantics` widget for clear labels on UI elements
- Test with TalkBack (Android) and VoiceOver (iOS)

## Documentation
- Use `///` for doc comments on public APIs
- Comment to explain WHY, not WHAT the code does
- Start doc comments with a single-sentence summary
- Don't add useless documentation that restates the obvious
