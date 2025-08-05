import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WaterQualityTrendChartWidget extends StatefulWidget {
  final String selectedRange;

  const WaterQualityTrendChartWidget({
    super.key,
    required this.selectedRange,
  });

  @override
  State<WaterQualityTrendChartWidget> createState() =>
      _WaterQualityTrendChartWidgetState();
}

class _WaterQualityTrendChartWidgetState
    extends State<WaterQualityTrendChartWidget> {
  int? touchedIndex;

  List<FlSpot> _generateTrendData() {
    switch (widget.selectedRange) {
      case 'Last 7 Days':
        return [
          const FlSpot(0, 7.2),
          const FlSpot(1, 7.4),
          const FlSpot(2, 7.1),
          const FlSpot(3, 7.6),
          const FlSpot(4, 7.3),
          const FlSpot(5, 7.8),
          const FlSpot(6, 7.5),
        ];
      case 'Month':
        return [
          const FlSpot(0, 7.1),
          const FlSpot(5, 7.3),
          const FlSpot(10, 7.5),
          const FlSpot(15, 7.2),
          const FlSpot(20, 7.7),
          const FlSpot(25, 7.4),
          const FlSpot(30, 7.6),
        ];
      case 'Quarter':
        return [
          const FlSpot(0, 7.0),
          const FlSpot(30, 7.2),
          const FlSpot(60, 7.4),
          const FlSpot(90, 7.3),
        ];
      case 'Year':
        return [
          const FlSpot(0, 6.8),
          const FlSpot(2, 7.1),
          const FlSpot(4, 7.3),
          const FlSpot(6, 7.2),
          const FlSpot(8, 7.5),
          const FlSpot(10, 7.4),
          const FlSpot(12, 7.6),
        ];
      default:
        return [
          const FlSpot(0, 7.2),
          const FlSpot(1, 7.4),
          const FlSpot(2, 7.1),
          const FlSpot(3, 7.6),
          const FlSpot(4, 7.3),
        ];
    }
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
                'Water Quality Trends',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              CustomIconWidget(
                iconName: 'info_outline',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            height: 25.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
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
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        );
                        Widget text;
                        switch (widget.selectedRange) {
                          case 'Last 7 Days':
                            final days = [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ];
                            text = Text(days[value.toInt() % days.length],
                                style: style);
                            break;
                          case 'Month':
                            text = Text('${value.toInt() + 1}', style: style);
                            break;
                          default:
                            text = Text('${value.toInt()}', style: style);
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 0.2,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                ),
                minX: 0,
                maxY: 8.5,
                minY: 6.5,
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateTrendData(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.lightTheme.primaryColor,
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.7),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.lightTheme.primaryColor,
                          strokeWidth: 2,
                          strokeColor: AppTheme.lightTheme.colorScheme.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.3),
                          AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        return LineTooltipItem(
                          'pH: ${barSpot.y.toStringAsFixed(1)}',
                          TextStyle(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'Average pH Level',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
