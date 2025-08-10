import 'package:butterfly/api/onyx.dart';
import 'package:flutter/material.dart';
import 'package:butterfly/src/generated/i18n/app_localizations.dart';
import 'package:material_leap/material_leap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class OnyxSettingsPage extends StatefulWidget {
  final bool inView;
  const OnyxSettingsPage({super.key, this.inView = false});

  @override
  State<OnyxSettingsPage> createState() => _OnyxSettingsPageState();
}

class _OnyxSettingsPageState extends State<OnyxSettingsPage> {
  OnyxStatus? _onyxStatus;
  EInkRefreshMode _currentMode = EInkRefreshMode.full;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOnyxStatus();
  }

  Future<void> _loadOnyxStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final status = await OnyxApi.getStatus();
      setState(() {
        _onyxStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setRefreshMode(EInkRefreshMode mode) async {
    if (_onyxStatus?.isReady != true) return;
    
    final success = await OnyxApi.setRefreshMode(mode);
    if (success) {
      setState(() => _currentMode = mode);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('E-ink mode set to ${mode.value}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _refreshScreen() async {
    if (_onyxStatus?.isReady != true) return;
    
    final success = await OnyxApi.refreshScreen();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? 'Screen refreshed successfully' 
            : 'Failed to refresh screen'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: widget.inView ? Colors.transparent : null,
      appBar: widget.inView
          ? null
          : AppBar(
              title: const Text('Onyx E-ink Settings'),
              backgroundColor: Colors.transparent,
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.inView) ...[
              const SizedBox(height: 8),
              Text(
                'E-ink Device Optimization',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
            ],
            
            // Device Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.deviceTablet(),
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Device Status',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else ...[
                      _StatusRow(
                        label: 'Onyx Device',
                        value: _onyxStatus?.isOnyxDevice == true ? 'Detected' : 'Not detected',
                        isPositive: _onyxStatus?.isOnyxDevice == true,
                      ),
                      _StatusRow(
                        label: 'SDK Initialized',
                        value: _onyxStatus?.isInitialized == true ? 'Yes' : 'No',
                        isPositive: _onyxStatus?.isInitialized == true,
                      ),
                      _StatusRow(
                        label: 'Optimizations',
                        value: _onyxStatus?.isReady == true ? 'Available' : 'Unavailable',
                        isPositive: _onyxStatus?.isReady == true,
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loadOnyxStatus,
                        icon: Icon(PhosphorIcons.arrowsCounterClockwise()),
                        label: const Text('Refresh Status'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // E-ink Settings Card
            if (_onyxStatus?.isReady == true) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.monitor(),
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Display Settings',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        'E-ink Refresh Mode',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      
                      // Refresh Mode Selection
                      Column(
                        children: EInkRefreshMode.values.map((mode) {
                          return RadioListTile<EInkRefreshMode>(
                            title: Text(_getModeTitle(mode)),
                            subtitle: Text(_getModeDescription(mode)),
                            value: mode,
                            groupValue: _currentMode,
                            onChanged: (value) {
                              if (value != null) {
                                _setRefreshMode(value);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Screen Refresh Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _refreshScreen,
                          icon: Icon(PhosphorIcons.arrowsClockwise()),
                          label: const Text('Refresh Screen'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.info(),
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'About Onyx Optimization',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Butterfly automatically optimizes drawing performance on Onyx e-ink devices. '
                        'When you draw with the pen tool, the app switches to fast refresh mode '
                        'for smooth writing, then returns to normal mode when finished.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        PhosphorIcons.deviceTablet(),
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Onyx Optimization Unavailable',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This device is not an Onyx e-ink tablet, or the Onyx SDK could not be initialized. '
                        'Butterfly will work normally without e-ink optimizations.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getModeTitle(EInkRefreshMode mode) {
    switch (mode) {
      case EInkRefreshMode.full:
        return 'Full Refresh';
      case EInkRefreshMode.du:
        return 'Direct Update (DU)';
      case EInkRefreshMode.a2:
        return 'A2 Fast Mode';
    }
  }

  String _getModeDescription(EInkRefreshMode mode) {
    switch (mode) {
      case EInkRefreshMode.full:
        return 'Highest quality, slower refresh';
      case EInkRefreshMode.du:
        return 'Balanced quality and speed';
      case EInkRefreshMode.a2:
        return 'Fastest refresh, ideal for drawing';
    }
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;

  const _StatusRow({
    required this.label,
    required this.value,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isPositive 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}