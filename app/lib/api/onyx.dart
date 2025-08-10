import 'dart:async';
import 'dart:developer' as developer;
import 'package:butterfly/main.dart';
import 'package:flutter/services.dart';

/// Onyx SDK integration for e-ink device optimization
class OnyxApi {
  static const String _tag = 'OnyxApi';
  
  // Cached device detection result
  static bool? _isOnyxDevice;
  static bool? _isInitialized;

  /// Check if the current device is an Onyx e-ink device
  static Future<bool> isOnyxDevice() async {
    if (_isOnyxDevice != null) return _isOnyxDevice!;
    
    try {
      final bool? result = await platform.invokeMethod('isOnyxDevice');
      _isOnyxDevice = result ?? false;
      developer.log('Onyx device detection: $_isOnyxDevice', name: _tag);
      return _isOnyxDevice!;
    } catch (e) {
      developer.log('Error detecting Onyx device: $e', name: _tag);
      _isOnyxDevice = false;
      return false;
    }
  }

  /// Check if Onyx SDK is properly initialized
  static Future<bool> isInitialized() async {
    if (_isInitialized != null) return _isInitialized!;
    
    try {
      final bool? result = await platform.invokeMethod('isOnyxInitialized');
      _isInitialized = result ?? false;
      developer.log('Onyx SDK initialization status: $_isInitialized', name: _tag);
      return _isInitialized!;
    } catch (e) {
      developer.log('Error checking Onyx initialization: $e', name: _tag);
      _isInitialized = false;
      return false;
    }
  }

  /// Set the e-ink refresh mode for optimal performance
  /// 
  /// Available modes:
  /// - 'full': Full refresh mode (highest quality, slowest)
  /// - 'du': Direct Update mode (balanced quality and speed)
  /// - 'a2': A2 mode (fastest, lowest quality - ideal for drawing)
  static Future<bool> setRefreshMode(EInkRefreshMode mode) async {
    try {
      final bool? result = await platform.invokeMethod('setEInkRefreshMode', {
        'mode': mode.value,
      });
      
      if (result == true) {
        developer.log('Set e-ink refresh mode to ${mode.value}', name: _tag);
      } else {
        developer.log('Failed to set e-ink refresh mode to ${mode.value}', name: _tag);
      }
      
      return result ?? false;
    } catch (e) {
      developer.log('Error setting e-ink refresh mode: $e', name: _tag);
      return false;
    }
  }

  /// Optimize the display for drawing operations
  /// 
  /// When enabled, switches to A2 mode for fast pen input.
  /// When disabled, returns to normal display mode.
  static Future<bool> optimizeForDrawing(bool enabled) async {
    try {
      final bool? result = await platform.invokeMethod('optimizeForDrawing', {
        'enabled': enabled,
      });
      
      if (result == true) {
        developer.log('Drawing optimization ${enabled ? 'enabled' : 'disabled'}', name: _tag);
      } else {
        developer.log('Failed to ${enabled ? 'enable' : 'disable'} drawing optimization', name: _tag);
      }
      
      return result ?? false;
    } catch (e) {
      developer.log('Error setting drawing optimization: $e', name: _tag);
      return false;
    }
  }

  /// Force a full screen refresh
  /// 
  /// Useful for clearing ghosting artifacts on e-ink displays
  static Future<bool> refreshScreen() async {
    try {
      final bool? result = await platform.invokeMethod('refreshScreen');
      
      if (result == true) {
        developer.log('Screen refresh triggered', name: _tag);
      } else {
        developer.log('Failed to trigger screen refresh', name: _tag);
      }
      
      return result ?? false;
    } catch (e) {
      developer.log('Error refreshing screen: $e', name: _tag);
      return false;
    }
  }

  /// Get comprehensive Onyx device status
  static Future<OnyxStatus> getStatus() async {
    final isDevice = await isOnyxDevice();
    final isInit = await isInitialized();
    
    return OnyxStatus(
      isOnyxDevice: isDevice,
      isInitialized: isInit,
    );
  }

  /// Reset cached values (useful for testing)
  static void resetCache() {
    _isOnyxDevice = null;
    _isInitialized = null;
  }
}

/// E-ink refresh modes available on Onyx devices
enum EInkRefreshMode {
  /// Full refresh mode - highest quality, slowest performance
  full('full'),
  
  /// Direct Update mode - balanced quality and performance  
  du('du'),
  
  /// A2 mode - fastest performance, ideal for drawing
  a2('a2');
  
  const EInkRefreshMode(this.value);
  final String value;
}

/// Status information about Onyx device and SDK
class OnyxStatus {
  final bool isOnyxDevice;
  final bool isInitialized;
  
  const OnyxStatus({
    required this.isOnyxDevice,
    required this.isInitialized,
  });
  
  /// Whether Onyx optimizations are available and ready to use
  bool get isReady => isOnyxDevice && isInitialized;
  
  @override
  String toString() {
    return 'OnyxStatus(device: $isOnyxDevice, initialized: $isInitialized, ready: $isReady)';
  }
}