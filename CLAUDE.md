# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Butterfly is a cross-platform note-taking app built with Flutter/Dart. It supports drawing, text editing, PDF/SVG export, and works on Android, iOS, Windows, Linux, macOS, and web platforms.

## Essential Development Commands

### Initial Setup
```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Running the App
```bash
flutter run  # Development mode
flutter run --release  # Release mode
```

### Code Generation
```bash
# Must run after modifying models with freezed/json_serializable annotations
dart run build_runner build --delete-conflicting-outputs
dart format .
```

### Testing
```bash
flutter test  # Run all tests
flutter test test/specific_test.dart  # Run specific test
```

### Code Quality
```bash
flutter analyze --fatal-infos  # Static analysis
dart format .  # Format code
```

### Building for Release
```bash
# Android
flutter build apk --release --flavor production

# iOS
flutter build ios --release --no-codesign

# Windows
flutter build windows --release

# Linux
flutter build linux --release

# macOS
flutter build macos --release

# Web
flutter build web
```

## Architecture Overview

### Core Structure
- `/app` - Main Flutter application
- `/api` - Core library for file handling and data models
- `/docs` - Documentation website (Astro)

### App Architecture (`/app/lib/`)
- `bloc/` - Document state management using BLoC pattern
- `handlers/` - Tool gesture handlers (pen, eraser, select, etc.)
- `renderers/` - Canvas rendering for elements and backgrounds
- `services/` - Background services (sync, import/export, networking)
- `models/` - App-specific data models (use freezed/json_serializable)
- `views/` - UI views and components

### API Architecture (`/api/lib/src/`)
- `models/` - Core data models (NoteData, Page, Element)
- `converter/` - File format converters
- `protocol/` - Collaboration event system

### State Management
Uses BLoC pattern with:
- `DocumentBloc` - Main document state
- Various Cubits for smaller state (settings, transform, current index)

### Key Technologies
- **Flutter 3.32.8** with Dart SDK >=3.8.0
- **State**: flutter_bloc, replay_bloc
- **File System**: Custom lw_file_system with WebDAV support
- **Graphics**: perfect_freehand (custom), flutter_svg
- **Networking**: Custom networker packages
- **Code Generation**: freezed, json_serializable

### Platform-Specific Code
- Platform implementations in `/app/lib/api/`
- Native file system integration for desktop
- Camera integration for mobile
- Progressive Web App configuration for web

### Onyx E-ink Device Support
Butterfly includes built-in support for Onyx Boox e-ink tablets:
- **Automatic detection** - Runtime detection of Onyx devices
- **Drawing optimization** - Fast refresh mode during pen input
- **SDK Integration** - Uses Onyx SDK for optimal e-ink performance
- **Settings UI** - User control panel at `/app/lib/settings/onyx.dart`
- **Handler Integration** - Mixin pattern for easy optimization of drawing tools

Key files:
- `/app/lib/api/onyx.dart` - Flutter API for Onyx functionality
- `/app/lib/handlers/onyx_mixin.dart` - Optimization mixin for handlers
- `/app/android/app/src/main/java/dev/linwood/butterfly/MainActivity.kt` - Native integration
- See `/app/lib/api/ONYX_INTEGRATION.md` for detailed documentation

### Development Notes
- Always run code generation after modifying models
- Main development branch is `develop`
- Use production flavor for release builds
- Internationalization via `flutter gen-l10n`