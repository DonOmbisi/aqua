import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WaterQualityMarkerWidget extends StatelessWidget {
  final Map<String, dynamic> markerData;
  final VoidCallback onTap;
  final bool isSelected;

  const WaterQualityMarkerWidget({
    Key? key,
    required this.markerData,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  Color _getQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return AppTheme.excellentWaterQuality;
      case 'good':
        return AppTheme.goodWaterQuality;
      case 'moderate':
        return AppTheme.moderateWaterQuality;
      case 'poor':
        return AppTheme.poorWaterQuality;
      case 'critical':
        return AppTheme.criticalWaterQuality;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quality = markerData['quality'] as String? ?? 'unknown';
    final markerColor = _getQualityColor(quality);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 12.w : 8.w,
        height: isSelected ? 12.w : 8.w,
        decoration: BoxDecoration(
          color: markerColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.surface,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: markerColor.withValues(alpha: 0.3),
              blurRadius: isSelected ? 12 : 8,
              spreadRadius: isSelected ? 2 : 1,
            ),
          ],
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'water_drop',
            color: AppTheme.lightTheme.colorScheme.surface,
            size: isSelected ? 20 : 16,
          ),
        ),
      ),
    );
  }
}
