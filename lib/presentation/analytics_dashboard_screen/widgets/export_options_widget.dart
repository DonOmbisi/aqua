import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExportOptionsWidget extends StatelessWidget {
  final String selectedRange;

  const ExportOptionsWidget({
    super.key,
    required this.selectedRange,
  });

  Future<void> _exportToPDF() async {
    final pdfContent = '''
    Water Quality Analytics Report
    Generated: ${DateTime.now().toString()}
    Date Range: $selectedRange
    
    Summary:
    - Total Monitoring Points: 156
    - Average Water Quality Score: 7.4/10
    - Issue Resolution Rate: 89%
    - Community Participation: 73%
    
    Key Findings:
    - pH levels remain stable across all monitoring points
    - Dissolved oxygen levels show improvement over selected period
    - Temperature variations within acceptable range
    - Turbidity levels require attention in 3 locations
    
    Recommendations:
    - Continue current monitoring protocols
    - Increase testing frequency in high-risk areas
    - Implement community education programs
    ''';

    await _downloadFile(pdfContent,
        'water_quality_report_${DateTime.now().millisecondsSinceEpoch}.txt');
  }

  Future<void> _exportToCSV() async {
    final csvContent = '''
Date,Location,pH,Dissolved_Oxygen,Temperature,Turbidity,Flow_Rate,Quality_Score
2025-07-21,Station A,7.2,8.5,22.5,15.2,1.8,8.2
2025-07-22,Station B,7.4,8.3,23.1,14.8,1.9,8.1
2025-07-23,Station C,7.1,8.7,21.9,16.1,1.7,7.9
2025-07-24,Station A,7.6,8.4,22.8,15.5,1.8,8.3
2025-07-25,Station B,7.3,8.6,23.2,14.9,1.9,8.0
2025-07-26,Station C,7.8,8.2,22.1,15.8,1.6,8.1
2025-07-27,Station A,7.5,8.5,22.7,15.3,1.8,8.2
''';

    await _downloadFile(csvContent,
        'water_quality_data_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  Future<void> _downloadFile(String content, String filename) async {
    try {
      if (kIsWeb) {
        // Web platform - use browser download
        // This would need proper web import handling
        print('Web download: $filename');
      } else {
        // For mobile platforms, this would require path_provider
        // For now, we'll show a success message
        print('File would be saved as: $filename');
      }
    } catch (e) {
      print('Export error: $e');
    }
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Export Analytics Data',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildExportOption(
              context,
              'PDF Report',
              'Complete analytics report with charts and insights',
              'picture_as_pdf',
              AppTheme.dataVisualizationColors[0],
              _exportToPDF,
            ),
            SizedBox(height: 2.h),
            _buildExportOption(
              context,
              'CSV Data',
              'Raw data for external analysis and processing',
              'table_chart',
              AppTheme.dataVisualizationColors[1],
              _exportToCSV,
            ),
            SizedBox(height: 2.h),
            _buildExportOption(
              context,
              'Share Link',
              'Generate shareable link for this analytics view',
              'share',
              AppTheme.dataVisualizationColors[2],
              () => _shareAnalytics(context),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context,
    String title,
    String description,
    String iconName,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title export initiated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 6.w,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }

  void _shareAnalytics(BuildContext context) {
    final shareText =
        'Check out these water quality analytics for $selectedRange. Generated on ${DateTime.now().toString().split(' ')[0]}';

    // Mobile sharing would use share_plus package
    // For now, just print the share text
    print('Share: $shareText');

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality would be implemented here'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showExportOptions(context),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: 'share',
          color: AppTheme.lightTheme.colorScheme.onPrimary,
          size: 5.w,
        ),
      ),
    );
  }
}
