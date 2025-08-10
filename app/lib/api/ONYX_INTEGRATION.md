# Onyx E-ink Device Integration

This document explains the Onyx e-ink device integration in Butterfly, which provides optimized performance for note-taking on Onyx Boox tablets.

## Overview

Butterfly includes built-in support for Onyx Boox e-ink devices through the Onyx SDK. This integration provides:

- **Automatic device detection** - No special configuration needed
- **Drawing optimization** - Switches to fast refresh mode during pen input
- **Screen refresh management** - Clears e-ink ghosting artifacts
- **Graceful fallback** - Works normally on non-Onyx devices

## Architecture

### Components

1. **Native Android Layer** (`MainActivity.kt`)
   - Onyx SDK initialization and runtime detection
   - Platform channel methods for Flutter communication
   - E-ink display mode management

2. **Flutter API Layer** (`/app/lib/api/onyx.dart`)
   - Dart interface to native Onyx functionality
   - Status checking and device detection
   - Refresh mode management

3. **Handler Integration** (`/app/lib/handlers/onyx_mixin.dart`)
   - Mixin for adding Onyx optimization to drawing handlers
   - Automatic optimization during drawing operations
   - Cleanup and state management

4. **Settings UI** (`/app/lib/settings/onyx.dart`)
   - User interface for Onyx device settings
   - Device status display
   - Manual refresh mode control

## Usage

### Basic Device Detection

```dart
import 'package:butterfly/api/onyx.dart';

// Check if running on Onyx device
final isOnyx = await OnyxApi.isOnyxDevice();

// Get comprehensive status
final status = await OnyxApi.getStatus();
if (status.isReady) {
  // Onyx optimizations available
}
```

### Drawing Optimization

```dart
// Enable fast drawing mode
await OnyxApi.optimizeForDrawing(true);

// Your drawing code here...

// Disable and return to normal mode
await OnyxApi.optimizeForDrawing(false);

// Optional: refresh screen to clear ghosting
await OnyxApi.refreshScreen();
```

### Refresh Mode Control

```dart
// Set specific e-ink refresh modes
await OnyxApi.setRefreshMode(EInkRefreshMode.a2);     // Fastest
await OnyxApi.setRefreshMode(EInkRefreshMode.du);     // Balanced
await OnyxApi.setRefreshMode(EInkRefreshMode.full);   // Highest quality
```

### Handler Integration

To add Onyx optimization to a drawing handler:

```dart
class MyHandler extends Handler<MyTool> with OnyxOptimizationMixin {
  
  @override
  void onPointerDown(PointerDownEvent event, EventContext context) {
    // Enable Onyx optimization when drawing starts
    enableOnyxDrawingOptimization();
    
    // Your existing pointer down logic
    // ...
  }
  
  @override
  void onPointerUp(PointerUpEvent event, EventContext context) {
    // Your existing pointer up logic first
    // ...
    
    // Disable Onyx optimization when drawing ends
    disableOnyxDrawingOptimization();
  }
  
  @override
  void resetInput(DocumentBloc bloc) {
    // Your existing reset logic
    // ...
    
    // Clean up Onyx optimization state
    disableOnyxDrawingOptimization();
  }
}
```

## E-ink Refresh Modes

### A2 Mode
- **Speed**: Fastest refresh
- **Quality**: Lower quality, monochrome
- **Use case**: Real-time drawing and writing
- **Auto-enabled**: During pen input operations

### DU (Direct Update) Mode
- **Speed**: Fast refresh
- **Quality**: Good quality with some limitations
- **Use case**: UI updates and navigation

### Full Mode
- **Speed**: Slowest refresh
- **Quality**: Highest quality
- **Use case**: Final document viewing, photos

## Implementation Details

### Device Detection

The integration uses `EpdDevice.isEpdDevice()` from the Onyx SDK to detect compatible devices at runtime. This check is cached for performance.

### Graceful Fallback

All Onyx API calls are wrapped in try-catch blocks and return appropriate fallback values on non-Onyx devices:

- Device detection returns `false`
- Optimization calls return `false` (indicating no action taken)
- All operations continue normally without Onyx features

### Performance Considerations

- Device detection is cached after the first check
- Optimization state is tracked to avoid redundant API calls
- Async operations don't block the drawing pipeline
- Screen refreshes are used sparingly to maintain performance

## Build Configuration

The Onyx SDK is included in all Android builds:

```kotlin
dependencies {
    implementation("com.onyx.android.sdk:onyxsdk-device:1.1.11")
    implementation("com.onyx.android.sdk:onyxsdk-pen:1.2.1")
}
```

Maven repositories:
```kotlin
repositories {
    maven { url = uri("https://jitpack.io") }
    maven { url = uri("http://repo.boox.com/repository/maven-public/") }
}
```

## Testing

### Manual Testing on Onyx Devices

1. Install Butterfly on an Onyx Boox device
2. Open Settings → Onyx E-ink Settings
3. Verify device detection shows "Detected"
4. Test drawing with the pen tool
5. Check logcat for optimization messages:
   ```
   ButterflyMainActivity: Onyx device detected, initializing SDK
   OnyxOptimization: Drawing optimization enabled
   ```

### Testing on Non-Onyx Devices

1. Install on regular Android device
2. Settings should show "Onyx Optimization Unavailable"
3. All functionality should work normally
4. No errors in logcat related to Onyx SDK

### Debug Logging

Enable debug logging to monitor Onyx integration:

```
adb logcat | grep -E "(ButterflyMainActivity|OnyxApi|OnyxOptimization)"
```

## Troubleshooting

### Common Issues

1. **"SDK not initialized" despite being on Onyx device**
   - Check device compatibility with Onyx SDK
   - Verify SDK dependencies are properly included
   - Check logcat for initialization errors

2. **Drawing optimization not working**
   - Verify device detection returns true
   - Check that handlers are using the OnyxOptimizationMixin
   - Ensure proper cleanup in handler lifecycle methods

3. **Screen refresh not working**
   - Check that device has proper Onyx SDK support
   - Verify app has necessary permissions
   - Try manual refresh from settings page

### Debug Commands

```dart
// Clear cached status for testing
OnyxApi.resetCache();
OnyxOptimizationMixin.clearCache();

// Check current optimization state
final isActive = handler.isOnyxOptimizationActive;
```

## Future Enhancements

Potential improvements to the Onyx integration:

1. **Pressure sensitivity optimization** - Better stylus pressure handling
2. **Palm rejection** - Enhanced palm rejection using Onyx APIs
3. **Custom refresh areas** - Partial screen refresh for better performance
4. **Gesture recognition** - Onyx-specific gesture support
5. **Battery optimization** - E-ink specific power management

## Related Files

- `/app/android/app/src/main/kotlin/dev/linwood/butterfly/MainActivity.kt` - Native integration
- `/app/lib/api/onyx.dart` - Flutter API interface
- `/app/lib/handlers/onyx_mixin.dart` - Handler integration mixin
- `/app/lib/handlers/pen_onyx_example.dart` - Integration example
- `/app/lib/settings/onyx.dart` - Settings UI
- `/app/android/app/build.gradle.kts` - Build configuration
- `/app/android/build.gradle.kts` - Repository configuration