import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapControlsWidget extends StatelessWidget {
  final VoidCallback onCurrentLocationTap;
  final VoidCallback onLayerToggle;
  final VoidCallback onReportHere;
  final bool isLocationLoading;
  final String currentLayer;

  const MapControlsWidget({
    Key? key,
    required this.onCurrentLocationTap,
    required this.onLayerToggle,
    required this.onReportHere,
    this.isLocationLoading = false,
    this.currentLayer = 'standard',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Current location button (bottom-right)
        Positioned(
          bottom: 20.h,
          right: 4.w,
          child: _buildControlButton(
            onTap: onCurrentLocationTap,
            icon: isLocationLoading ? 'hourglass_empty' : 'my_location',
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            iconColor: AppTheme.lightTheme.colorScheme.primary,
            isLoading: isLocationLoading,
          ),
        ),

        // Layer toggle button (bottom-right, above location)
        Positioned(
          bottom: 26.h,
          right: 4.w,
          child: _buildControlButton(
            onTap: onLayerToggle,
            icon: currentLayer == 'satellite' ? 'map' : 'satellite',
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            iconColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),

        // Report here FAB (bottom-center)
        Positioned(
          bottom: 12.h,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton.extended(
              onPressed: onReportHere,
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
              elevation: 6,
              icon: CustomIconWidget(
                iconName: 'add_location',
                color: AppTheme.lightTheme.colorScheme.onSecondary,
                size: 24,
              ),
              label: Text(
                'Report Here',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        // GPS accuracy indicator (top-right)
        Positioned(
          top: 12.h,
          right: 4.w,
          child: _buildGpsAccuracyIndicator(),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required VoidCallback onTap,
    required String icon,
    required Color backgroundColor,
    required Color iconColor,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                )
              : CustomIconWidget(
                  iconName: icon,
                  color: iconColor,
                  size: 24,
                ),
        ),
      ),
    );
  }

  Widget _buildGpsAccuracyIndicator() {
    // Mock GPS accuracy - in real app this would come from location services
    final accuracy = 'High'; // High, Medium, Low
    final accuracyColor = accuracy == 'High'
        ? AppTheme.excellentWaterQuality
        : accuracy == 'Medium'
            ? AppTheme.moderateWaterQuality
            : AppTheme.poorWaterQuality;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: accuracyColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            'GPS: $accuracy',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
