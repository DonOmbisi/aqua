import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ParameterComparisonChartWidget extends StatefulWidget {
  final String selectedRange;

  const ParameterComparisonChartWidget({
    super.key,
    required this.selectedRange,
  });

  @override
  State<ParameterComparisonChartWidget> createState() =>
      _ParameterComparisonChartWidgetState();
}

class _ParameterComparisonChartWidgetState
    extends State<ParameterComparisonChartWidget> {
  int touchedIndex = -1;

  List<BarChartGroupData> _generateBarData() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: 7.2,
            color: AppTheme.dataVisualizationColors[0],
            width: 4.w,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: 8.5,
            color: AppTheme.dataVisualizationColors[1],
            width: 4.w,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: 22.5,
            color: AppTheme.dataVisualizationColors[2],
            width: 4.w,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: 15.2,
            color: AppTheme.dataVisualizationColors[3],
            width: 4.w,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(
            toY: 1.8,
            color: AppTheme.dataVisualizationColors[4],
            width: 4.w,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Parameter Comparison',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Show parameter details
                },
                child: CustomIconWidget(
                  iconName: 'more_vert',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            height: 25.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 25,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final parameters = [
                        'pH',
                        'DO',
                        'Temp',
                        'Turbidity',
                        'Flow'
                      ];
                      final units = ['', 'mg/L', '°C', 'NTU', 'm³/s'];
                      return BarTooltipItem(
                        '${parameters[group.x]}: ${rod.toY.toStringAsFixed(1)}${units[group.x]}',
                        TextStyle(
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = const Text('pH', style: style);
                            break;
                          case 1:
                            text = const Text('DO', style: style);
                            break;
                          case 2:
                            text = const Text('Temp', style: style);
                            break;
                          case 3:
                            text = const Text('Turbidity', style: style);
                            break;
                          case 4:
                            text = const Text('Flow', style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: text,
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 5,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: _generateBarData(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 3.w,
            runSpacing: 1.h,
            children: [
              _buildLegendItem('pH Level', AppTheme.dataVisualizationColors[0]),
              _buildLegendItem(
                  'Dissolved O₂', AppTheme.dataVisualizationColors[1]),
              _buildLegendItem(
                  'Temperature', AppTheme.dataVisualizationColors[2]),
              _buildLegendItem(
                  'Turbidity', AppTheme.dataVisualizationColors[3]),
              _buildLegendItem(
                  'Flow Rate', AppTheme.dataVisualizationColors[4]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
