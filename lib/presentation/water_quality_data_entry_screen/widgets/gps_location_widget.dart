import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class GpsLocationWidget extends StatefulWidget {
  final Function(double lat, double lng, double accuracy) onLocationUpdate;
  final double? initialLatitude;
  final double? initialLongitude;
  final double? initialAccuracy;

  const GpsLocationWidget({
    Key? key,
    required this.onLocationUpdate,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAccuracy,
  }) : super(key: key);

  @override
  State<GpsLocationWidget> createState() => _GpsLocationWidgetState();
}

class _GpsLocationWidgetState extends State<GpsLocationWidget> {
  bool _isLoadingLocation = false;
  double? _latitude;
  double? _longitude;
  double? _accuracy;
  bool _manualOverride = false;
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
    _accuracy = widget.initialAccuracy;

    if (_latitude != null && _longitude != null) {
      _latController.text = _latitude!.toStringAsFixed(6);
      _lngController.text = _longitude!.toStringAsFixed(6);
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Simulate GPS location fetch - in real app would use geolocator package
      await Future.delayed(const Duration(seconds: 2));

      // Mock GPS coordinates for demonstration
      final mockLat = 40.7128 + (DateTime.now().millisecond / 100000);
      final mockLng = -74.0060 + (DateTime.now().millisecond / 100000);
      final mockAccuracy = 3.5 + (DateTime.now().millisecond % 10);

      setState(() {
        _latitude = mockLat;
        _longitude = mockLng;
        _accuracy = mockAccuracy;
        _latController.text = _latitude!.toStringAsFixed(6);
        _lngController.text = _longitude!.toStringAsFixed(6);
      });

      widget.onLocationUpdate(_latitude!, _longitude!, _accuracy!);
    } catch (e) {
      // Handle location error gracefully
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _toggleManualOverride() {
    setState(() {
      _manualOverride = !_manualOverride;
    });
  }

  void _updateManualLocation() {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);

    if (lat != null && lng != null) {
      setState(() {
        _latitude = lat;
        _longitude = lng;
        _accuracy = 0.0; // Manual entry has no accuracy
      });
      widget.onLocationUpdate(_latitude!, _longitude!, _accuracy!);
    }
  }

  Color _getAccuracyColor() {
    if (_accuracy == null) return AppTheme.lightTheme.colorScheme.outline;
    if (_accuracy! <= 5) return AppTheme.lightTheme.colorScheme.tertiary;
    if (_accuracy! <= 10) return AppTheme.warningLight;
    return AppTheme.lightTheme.colorScheme.error;
  }

  String _getAccuracyText() {
    if (_accuracy == null) return 'Unknown';
    if (_accuracy! <= 5) return 'Excellent';
    if (_accuracy! <= 10) return 'Good';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'GPS Location',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              const Spacer(),
              if (_isLoadingLocation)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                )
              else
                GestureDetector(
                  onTap: _getCurrentLocation,
                  child: CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
            ],
          ),
          SizedBox(height: 3.h),
          if (_latitude != null && _longitude != null) ...[
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _getAccuracyColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getAccuracyColor().withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latitude',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                            Text(
                              _latitude!.toStringAsFixed(6),
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Longitude',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                            Text(
                              _longitude!.toStringAsFixed(6),
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'gps_fixed',
                        color: _getAccuracyColor(),
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Accuracy: ${_accuracy?.toStringAsFixed(1) ?? 'N/A'}m (${_getAccuracyText()})',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: _getAccuracyColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleManualOverride,
                  icon: CustomIconWidget(
                    iconName: _manualOverride ? 'gps_fixed' : 'edit_location',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                  label: Text(_manualOverride ? 'Use GPS' : 'Manual Entry'),
                ),
              ),
            ],
          ),
          if (_manualOverride) ...[
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      hintText: '40.712800',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _updateManualLocation(),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      hintText: '-74.006000',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _updateManualLocation(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }
}
