import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/connection_status_widget.dart';
import './widgets/activity_feed_widget.dart';
import './widgets/header_widget.dart';
import './widgets/metric_card_widget.dart';
import './widgets/quick_stats_widget.dart';
import './widgets/trend_chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  late TabController _tabController;

  // Mock user data
  final Map<String, dynamic> currentUser = {
    "id": 1,
    "name": "Dr. Sarah Johnson",
    "role": "manager",
    "email": "sarah.johnson@aquahorizon.com",
    "location": "San Francisco Bay Area, CA",
    "avatar":
        "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
  };

  // Mock dashboard data
  final List<Map<String, dynamic>> waterQualityMetrics = [
    {
      "id": 1,
      "title": "pH Level",
      "value": "7.2",
      "unit": "pH",
      "status": "good",
      "trend": "+0.3 from yesterday",
      "location": "Marina District",
      "timestamp": "2025-07-28T06:30:00Z",
    },
    {
      "id": 2,
      "title": "Turbidity",
      "value": "2.8",
      "unit": "NTU",
      "status": "excellent",
      "trend": "-0.5 from yesterday",
      "location": "Golden Gate Park",
      "timestamp": "2025-07-28T06:25:00Z",
    },
    {
      "id": 3,
      "title": "Dissolved Oxygen",
      "value": "8.5",
      "unit": "mg/L",
      "status": "good",
      "trend": "+1.2 from yesterday",
      "location": "Presidio",
      "timestamp": "2025-07-28T06:20:00Z",
    },
    {
      "id": 4,
      "title": "Temperature",
      "value": "18.5",
      "unit": "°C",
      "status": "moderate",
      "trend": "+2.1 from yesterday",
      "location": "Fisherman's Wharf",
      "timestamp": "2025-07-28T06:15:00Z",
    },
  ];

  final List<Map<String, dynamic>> recentActivities = [
    {
      "id": 1,
      "type": "water_quality",
      "userName": "Michael Chen",
      "userAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "description":
          "Submitted pH and turbidity readings for Marina District monitoring station",
      "location": "Marina District, SF",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 15)),
      "status": "verified",
    },
    {
      "id": 2,
      "type": "issue_report",
      "userName": "Emma Rodriguez",
      "userAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "description": "Reported unusual water discoloration near Pier 39",
      "location": "Pier 39, SF",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "status": "investigating",
    },
    {
      "id": 3,
      "type": "discussion",
      "userName": "Dr. James Wilson",
      "userAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "description":
          "Started discussion about seasonal water quality patterns in the bay",
      "location": "Community Forum",
      "timestamp": DateTime.now().subtract(const Duration(hours: 4)),
      "status": "active",
    },
    {
      "id": 4,
      "type": "water_quality",
      "userName": "Lisa Park",
      "userAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "description":
          "Completed weekly water sampling at Golden Gate Park reservoir",
      "location": "Golden Gate Park, SF",
      "timestamp": DateTime.now().subtract(const Duration(hours: 6)),
      "status": "verified",
    },
    {
      "id": 5,
      "type": "issue_report",
      "userName": "Carlos Martinez",
      "userAvatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "description": "Reported potential algae bloom in Stow Lake",
      "location": "Stow Lake, SF",
      "timestamp": DateTime.now().subtract(const Duration(hours: 8)),
      "status": "resolved",
    },
  ];

  final Map<String, dynamic> quickStats = {
    "activeReports": 12,
    "dataPoints": 1847,
    "communityUsers": 324,
    "lastSync": "2 min ago",
  };

  final List<Map<String, dynamic>> chartData = [
    {"day": "Mon", "value": 7.1},
    {"day": "Tue", "value": 7.3},
    {"day": "Wed", "value": 6.9},
    {"day": "Thu", "value": 7.2},
    {"day": "Fri", "value": 7.4},
    {"day": "Sat", "value": 7.0},
    {"day": "Sun", "value": 7.2},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Dashboard data refreshed'),
          backgroundColor: AppTheme.successLight,
          duration: const Duration(seconds: 2)));
    }
  }

  void _showContextMenu(Map<String, dynamic> activity) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => Container(
            padding: EdgeInsets.all(4.w),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                      color: AppTheme.lightTheme.dividerColor,
                      borderRadius: BorderRadius.circular(2))),
              SizedBox(height: 2.h),
              ListTile(
                  leading: CustomIconWidget(
                      iconName: 'visibility',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 24),
                  title: const Text('View Details'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to activity details
                  }),
              ListTile(
                  leading: CustomIconWidget(
                      iconName: 'share',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24),
                  title: const Text('Share'),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle share
                  }),
              ListTile(
                  leading: CustomIconWidget(
                      iconName: 'flag', color: AppTheme.warningLight, size: 24),
                  title: const Text('Flag Issue'),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle flag
                  }),
              SizedBox(height: 2.h),
            ])));
  }

  void _navigateToQuickReport() {
    Navigator.pushNamed(context, '/water-quality-data-entry-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Column(children: [
          HeaderWidget(
              userName: currentUser['name'] as String,
              userRole: currentUser['role'] as String,
              location: currentUser['location'] as String,
              weatherCondition: 'Cloudy',
              temperature: '16',
              onProfileTap: () {
                // Navigate to profile
              }),
          Expanded(
              child: TabBarView(controller: _tabController, children: [
            _buildDashboardTab(),
            _buildMapTab(),
            _buildReportsTab(),
            _buildProfileTab(),
          ])),
        ]),
        bottomNavigationBar: Container(
            decoration:
                BoxDecoration(color: AppTheme.lightTheme.cardColor, boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2)),
            ]),
            child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.lightTheme.primaryColor,
                unselectedLabelColor:
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                indicatorColor: AppTheme.lightTheme.primaryColor,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                      icon: CustomIconWidget(
                          iconName: 'dashboard',
                          color: _currentTabIndex == 0
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 24),
                      text: 'Dashboard'),
                  Tab(
                      icon: CustomIconWidget(
                          iconName: 'map',
                          color: _currentTabIndex == 1
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 24),
                      text: 'Map'),
                  Tab(
                      icon: CustomIconWidget(
                          iconName: 'assessment',
                          color: _currentTabIndex == 2
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 24),
                      text: 'Reports'),
                  Tab(
                      icon: CustomIconWidget(
                          iconName: 'person',
                          color: _currentTabIndex == 3
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 24),
                      text: 'Profile'),
                ],
                onTap: (index) {
                  setState(() {
                    _currentTabIndex = index;
                  });
                })),
        floatingActionButton: _currentTabIndex == 0
            ? FloatingActionButton.extended(
                onPressed: _navigateToQuickReport,
                backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                foregroundColor: AppTheme.lightTheme.colorScheme.onSecondary,
                icon: CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.lightTheme.colorScheme.onSecondary,
                    size: 24),
                label: Text('Quick Report',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSecondary,
                        fontWeight: FontWeight.w600)))
            : null);
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.lightTheme.primaryColor,
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: 1.h),
              // Connection status indicator
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: const Align(
                      alignment: Alignment.centerRight,
                      child: ConnectionStatusWidget())),
              SizedBox(height: 1.h),
              QuickStatsWidget(stats: quickStats),
              SizedBox(height: 2.h),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text('Water Quality Metrics',
                      style: AppTheme.lightTheme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600))),
              SizedBox(height: 1.h),
              SizedBox(
                  height: 22.h,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      itemCount: waterQualityMetrics.length,
                      itemBuilder: (context, index) {
                        final metric = waterQualityMetrics[index];
                        return MetricCardWidget(
                            title: metric['title'] as String,
                            value: metric['value'] as String,
                            unit: metric['unit'] as String,
                            status: metric['status'] as String,
                            trend: metric['trend'] as String,
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/analytics-dashboard-screen');
                            },
                            onSwipeRight: () {
                              // Show detailed trends
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Showing detailed trends for ${metric['title']}'),
                                  duration: const Duration(seconds: 2)));
                            });
                      })),
              SizedBox(height: 2.h),
              TrendChartWidget(
                  chartData: chartData,
                  title: 'pH Levels - Weekly Trend',
                  parameter: 'ph'),
              SizedBox(height: 2.h),
              ActivityFeedWidget(
                  activities: recentActivities,
                  onItemTap: (activity) {
                    // Navigate to activity details
                  },
                  onItemLongPress: (activity) {
                    _showContextMenu(activity);
                  }),
              SizedBox(height: 10.h), // Space for FAB
            ])));
  }

  Widget _buildMapTab() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CustomIconWidget(
          iconName: 'map',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 64),
      SizedBox(height: 2.h),
      Text('Map View',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
      SizedBox(height: 1.h),
      ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/map-view-screen');
          },
          child: const Text('Open Full Map')),
    ]));
  }

  Widget _buildReportsTab() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CustomIconWidget(
          iconName: 'assessment',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 64),
      SizedBox(height: 2.h),
      Text('Reports & Analytics',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
      SizedBox(height: 1.h),
      ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/analytics-dashboard-screen');
          },
          child: const Text('View Analytics')),
    ]));
  }

  Widget _buildProfileTab() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)),
          child: CustomIconWidget(
              iconName: 'person',
              color: AppTheme.lightTheme.primaryColor,
              size: 48)),
      SizedBox(height: 2.h),
      Text(currentUser['name'] as String,
          style: AppTheme.lightTheme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w600)),
      SizedBox(height: 0.5.h),
      Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Text((currentUser['role'] as String).toUpperCase(),
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600))),
      SizedBox(height: 2.h),
      ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login-screen');
          },
          child: const Text('Logout')),
    ]));
  }
}
