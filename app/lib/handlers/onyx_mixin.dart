import 'dart:developer' as developer;
import 'package:butterfly/api/onyx.dart';
import 'package:flutter/gestures.dart';

/// Mixin to add Onyx e-ink device optimization to handlers
/// 
/// This mixin automatically optimizes the display for drawing operations
/// when used on Onyx devices, providing better pen input performance.
mixin OnyxOptimizationMixin {
  static const String _tag = 'OnyxOptimization';
  
  // Track whether we've enabled drawing optimization
  bool _onyxDrawingOptimizationEnabled = false;
  
  // Cache Onyx status to avoid repeated API calls
  static OnyxStatus? _cachedStatus;
  static DateTime? _cacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 1);

  /// Get cached Onyx status or fetch fresh if needed
  Future<OnyxStatus> _getOnyxStatus() async {
    final now = DateTime.now();
    
    // Return cached status if still valid
    if (_cachedStatus != null && 
        _cacheTime != null && 
        now.difference(_cacheTime!).abs() < _cacheValidDuration) {
      return _cachedStatus!;
    }
    
    // Fetch fresh status
    _cachedStatus = await OnyxApi.getStatus();
    _cacheTime = now;
    
    return _cachedStatus!;
  }

  /// Enable Onyx drawing optimization if available
  /// 
  /// Should be called when drawing operations begin (e.g., onPointerDown)
  Future<void> enableOnyxDrawingOptimization() async {
    if (_onyxDrawingOptimizationEnabled) return;
    
    try {
      final status = await _getOnyxStatus();
      
      if (status.isReady) {
        final success = await OnyxApi.optimizeForDrawing(true);
        if (success) {
          _onyxDrawingOptimizationEnabled = true;
          developer.log('Onyx drawing optimization enabled', name: _tag);
        } else {
          developer.log('Failed to enable Onyx drawing optimization', name: _tag);
        }
      }
    } catch (e) {
      developer.log('Error enabling Onyx drawing optimization: $e', name: _tag);
    }
  }

  /// Disable Onyx drawing optimization
  /// 
  /// Should be called when drawing operations end (e.g., onPointerUp)
  Future<void> disableOnyxDrawingOptimization() async {
    if (!_onyxDrawingOptimizationEnabled) return;
    
    try {
      final status = await _getOnyxStatus();
      
      if (status.isReady) {
        final success = await OnyxApi.optimizeForDrawing(false);
        if (success) {
          _onyxDrawingOptimizationEnabled = false;
          developer.log('Onyx drawing optimization disabled', name: _tag);
        } else {
          developer.log('Failed to disable Onyx drawing optimization', name: _tag);
        }
      }
    } catch (e) {
      developer.log('Error disabling Onyx drawing optimization: $e', name: _tag);
    }
  }

  /// Trigger a screen refresh to clear e-ink ghosting
  /// 
  /// Useful to call after complex drawing operations are complete
  Future<void> refreshOnyxScreen() async {
    try {
      final status = await _getOnyxStatus();
      
      if (status.isReady) {
        final success = await OnyxApi.refreshScreen();
        if (success) {
          developer.log('Onyx screen refresh triggered', name: _tag);
        } else {
          developer.log('Failed to trigger Onyx screen refresh', name: _tag);
        }
      }
    } catch (e) {
      developer.log('Error triggering Onyx screen refresh: $e', name: _tag);
    }
  }

  /// Set a specific e-ink refresh mode
  /// 
  /// Useful for handlers that need specific display characteristics
  Future<bool> setOnyxRefreshMode(EInkRefreshMode mode) async {
    try {
      final status = await _getOnyxStatus();
      
      if (status.isReady) {
        final success = await OnyxApi.setRefreshMode(mode);
        if (success) {
          developer.log('Onyx refresh mode set to ${mode.value}', name: _tag);
        } else {
          developer.log('Failed to set Onyx refresh mode to ${mode.value}', name: _tag);
        }
        return success;
      }
      
      return false;
    } catch (e) {
      developer.log('Error setting Onyx refresh mode: $e', name: _tag);
      return false;
    }
  }

  /// Check if Onyx optimization is currently active
  bool get isOnyxOptimizationActive => _onyxDrawingOptimizationEnabled;

  /// Helper method to wrap pointer down events with Onyx optimization
  void onPointerDownWithOnyx(PointerDownEvent event, Function(PointerDownEvent) originalHandler) {
    // Enable Onyx optimization asynchronously (don't block the drawing)
    enableOnyxDrawingOptimization();
    
    // Call the original handler
    originalHandler(event);
  }

  /// Helper method to wrap pointer up events with Onyx optimization cleanup
  void onPointerUpWithOnyx(PointerUpEvent event, Function(PointerUpEvent) originalHandler) {
    // Call the original handler first
    originalHandler(event);
    
    // Disable Onyx optimization asynchronously
    disableOnyxDrawingOptimization();
  }

  /// Clear any cached Onyx status (useful for testing)
  static void clearCache() {
    _cachedStatus = null;
    _cacheTime = null;
  }
}