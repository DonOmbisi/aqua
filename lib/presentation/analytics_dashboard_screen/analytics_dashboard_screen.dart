import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/export_options_widget.dart';
import './widgets/filter_panel_widget.dart';
import './widgets/issue_categories_pie_chart_widget.dart';
import './widgets/metric_card_widget.dart';
import './widgets/parameter_comparison_chart_widget.dart';
import './widgets/water_quality_trend_chart_widget.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 2; // Analytics tab active
  String _selectedDateRange = 'Last 7 Days';
  bool _isRefreshing = false;
  late TabController _tabController;

  Map<String, dynamic> _currentFilters = {
    'parameters': <String>[],
    'locations': 'All Locations',
    'dataSources': 'All Sources',
    'qualityRange': const RangeValues(0, 10),
    'showOnlyIssues': false,
  };

  final List<Map<String, dynamic>> _mockMetrics = [
    {
      'title': 'Monitoring Points',
      'value': '156',
      'subtitle': '+12 this month',
      'iconName': 'location_on',
      'color': AppTheme.dataVisualizationColors[0],
    },
    {
      'title': 'Avg Quality Score',
      'value': '7.4',
      'subtitle': '↑ 0.3 from last period',
      'iconName': 'water_drop',
      'color': AppTheme.dataVisualizationColors[1],
    },
    {
      'title': 'Issue Resolution',
      'value': '89%',
      'subtitle': '↑ 5% improvement',
      'iconName': 'check_circle',
      'color': AppTheme.dataVisualizationColors[2],
    },
    {
      'title': 'Community Participation',
      'value': '73%',
      'subtitle': '2,341 active users',
      'iconName': 'people',
      'color': AppTheme.dataVisualizationColors[3],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this, initialIndex: _selectedTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analytics data updated'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onDateRangeChanged(String range) {
    setState(() {
      _selectedDateRange = range;
    });
  }

  void _onFiltersChanged(Map<String, dynamic> filters) {
    setState(() {
      _currentFilters = filters;
    });
  }

  void _onCategoryTapped(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtering by $category issues'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToScreen(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Analytics Dashboard',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        actions: [
          FilterPanelWidget(
            onFiltersChanged: _onFiltersChanged,
            currentFilters: _currentFilters,
          ),
          SizedBox(width: 2.w),
          ExportOptionsWidget(selectedRange: _selectedDateRange),
          SizedBox(width: 4.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.lightTheme.primaryColor,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  DateRangeSelectorWidget(
                    onRangeSelected: _onDateRangeChanged,
                    selectedRange: _selectedDateRange,
                  ),
                  SizedBox(height: 2.h),
                  if (_isRefreshing)
                    Container(
                      padding: EdgeInsets.all(4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 4.w,
                            height: 4.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.lightTheme.primaryColor,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Updating analytics...',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final metric = _mockMetrics[index];
                    return MetricCardWidget(
                      title: metric['title'],
                      value: metric['value'],
                      subtitle: metric['subtitle'],
                      iconName: metric['iconName'],
                      iconColor: metric['color'],
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${metric['title']} details'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
                  childCount: _mockMetrics.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  WaterQualityTrendChartWidget(
                      selectedRange: _selectedDateRange),
                  ParameterComparisonChartWidget(
                      selectedRange: _selectedDateRange),
                  IssueCategoriesPieChartWidget(
                      onCategoryTap: _onCategoryTapped),
                  SizedBox(height: 10.h), // Space for bottom navigation
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor:
              AppTheme.lightTheme.bottomNavigationBarTheme.backgroundColor,
          selectedItemColor:
              AppTheme.lightTheme.bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor:
              AppTheme.lightTheme.bottomNavigationBarTheme.unselectedItemColor,
          elevation: AppTheme.lightTheme.bottomNavigationBarTheme.elevation,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });

            switch (index) {
              case 0:
                _navigateToScreen('/dashboard-screen');
                break;
              case 1:
                _navigateToScreen('/map-view-screen');
                break;
              case 2:
                // Already on analytics dashboard
                break;
              case 3:
                _navigateToScreen('/water-quality-data-entry-screen');
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'dashboard',
                color: _selectedTabIndex == 0
                    ? AppTheme
                        .lightTheme.bottomNavigationBarTheme.selectedItemColor!
                    : AppTheme.lightTheme.bottomNavigationBarTheme
                        .unselectedItemColor!,
                size: 6.w,
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'map',
                color: _selectedTabIndex == 1
                    ? AppTheme
                        .lightTheme.bottomNavigationBarTheme.selectedItemColor!
                    : AppTheme.lightTheme.bottomNavigationBarTheme
                        .unselectedItemColor!,
                size: 6.w,
              ),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'analytics',
                color: _selectedTabIndex == 2
                    ? AppTheme
                        .lightTheme.bottomNavigationBarTheme.selectedItemColor!
                    : AppTheme.lightTheme.bottomNavigationBarTheme
                        .unselectedItemColor!,
                size: 6.w,
              ),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'add_circle',
                color: _selectedTabIndex == 3
                    ? AppTheme
                        .lightTheme.bottomNavigationBarTheme.selectedItemColor!
                    : AppTheme.lightTheme.bottomNavigationBarTheme
                        .unselectedItemColor!,
                size: 6.w,
              ),
              label: 'Add Data',
            ),
          ],
        ),
      ),
    );
  }
}
