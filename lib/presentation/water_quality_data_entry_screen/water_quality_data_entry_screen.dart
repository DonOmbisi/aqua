import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/gps_location_widget.dart';
import './widgets/notes_section_widget.dart';
import './widgets/photo_capture_widget.dart';
import './widgets/water_parameters_widget.dart';

class WaterQualityDataEntryScreen extends StatefulWidget {
  const WaterQualityDataEntryScreen({Key? key}) : super(key: key);

  @override
  State<WaterQualityDataEntryScreen> createState() =>
      _WaterQualityDataEntryScreenState();
}

class _WaterQualityDataEntryScreenState
    extends State<WaterQualityDataEntryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSubmitting = false;
  bool _isDraft = false;

  // Data collection variables
  double? _latitude;
  double? _longitude;
  double? _accuracy;
  List<String> _photos = [];
  Map<String, dynamic> _waterParameters = {};
  String _notes = '';

  // Form validation
  bool get _isFormValid {
    return _latitude != null &&
        _longitude != null &&
        _waterParameters.isNotEmpty &&
        _waterParameters['ph'] != null &&
        _waterParameters['turbidity'] != null;
  }

  void _onLocationUpdate(double lat, double lng, double accuracy) {
    setState(() {
      _latitude = lat;
      _longitude = lng;
      _accuracy = accuracy;
    });
  }

  void _onPhotosUpdate(List<String> photos) {
    setState(() {
      _photos = photos;
    });
  }

  void _onParametersUpdate(Map<String, dynamic> parameters) {
    setState(() {
      _waterParameters = parameters;
    });
  }

  void _onNotesUpdate(String notes) {
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _saveDraft() async {
    setState(() => _isDraft = true);

    try {
      // Simulate saving draft
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Draft saved successfully'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save draft'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isDraft = false);
    }
  }

  Future<void> _submitData() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please complete required fields (GPS location and basic water parameters)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Simulate data submission
      await Future.delayed(const Duration(seconds: 3));

      // Data would be submitted here in a real implementation
      // final submissionData = {
      //   'timestamp': DateTime.now().toIso8601String(),
      //   'location': {
      //     'latitude': _latitude,
      //     'longitude': _longitude,
      //     'accuracy': _accuracy,
      //   },
      //   'photos': _photos,
      //   'parameters': _waterParameters,
      //   'notes': _notes,
      //   'submitted_by': 'current_user_id',
      // };

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                const Text('Data Submitted Successfully'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your water quality data has been submitted and will be processed for analysis.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submission Summary:',
                        style: AppTheme.lightTheme.textTheme.titleSmall,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                          '• Location: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'),
                      Text('• Photos: ${_photos.length} attached'),
                      Text(
                          '• pH Level: ${_waterParameters['ph']?.toStringAsFixed(1) ?? 'N/A'}'),
                      Text(
                          '• Turbidity: ${_waterParameters['turbidity']?.toStringAsFixed(1) ?? 'N/A'} NTU'),
                      Text(
                          '• Temperature: ${_waterParameters['temperature']?.toStringAsFixed(1) ?? 'N/A'}°${_waterParameters['temperature_unit'] ?? 'C'}'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to previous screen
                },
                child: const Text('Done'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  _resetForm();
                },
                child: const Text('Submit Another'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to submit data. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    setState(() {
      _latitude = null;
      _longitude = null;
      _accuracy = null;
      _photos = [];
      _waterParameters = {};
      _notes = '';
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Data Entry'),
        content: const Text(
            'Are you sure you want to cancel? Any unsaved data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Editing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header with stack navigation
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow
                        .withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showCancelDialog,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      child: Text(
                        'Cancel',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Water Quality Data',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Field Data Collection',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _isDraft ? null : _saveDraft,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      child: _isDraft
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            )
                          : Text(
                              'Save',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable form content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GPS Location Widget
                    GpsLocationWidget(
                      onLocationUpdate: _onLocationUpdate,
                      initialLatitude: _latitude,
                      initialLongitude: _longitude,
                      initialAccuracy: _accuracy,
                    ),

                    SizedBox(height: 3.h),

                    // Photo Capture Widget
                    PhotoCaptureWidget(
                      onPhotosUpdate: _onPhotosUpdate,
                      initialPhotos: _photos,
                      latitude: _latitude,
                      longitude: _longitude,
                    ),

                    SizedBox(height: 3.h),

                    // Water Parameters Widget
                    WaterParametersWidget(
                      onParametersUpdate: _onParametersUpdate,
                      initialParameters: _waterParameters,
                    ),

                    SizedBox(height: 3.h),

                    // Notes Section Widget
                    NotesSectionWidget(
                      onNotesUpdate: _onNotesUpdate,
                      initialNotes: _notes,
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow
                        .withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Form validation indicator
                  if (!_isFormValid)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.error
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.error
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'warning',
                            color: AppTheme.lightTheme.colorScheme.error,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'GPS location and basic water parameters are required',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                const Text('Submitting Data...'),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'cloud_upload',
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                const Text('Submit Data'),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
