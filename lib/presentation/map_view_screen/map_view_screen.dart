import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bottom_navigation_widget.dart';
import './widgets/map_controls_widget.dart';
import './widgets/map_filter_bottom_sheet_widget.dart';
import './widgets/map_search_bar_widget.dart';
import './widgets/marker_callout_widget.dart';
import './widgets/water_quality_marker_widget.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen>
    with TickerProviderStateMixin {
  int _currentBottomNavIndex = 1; // Map tab active
  bool _isLocationLoading = false;
  String _currentMapLayer = 'standard';
  Map<String, dynamic> _selectedMarker = {};
  bool _showCallout = false;
  Map<String, dynamic> _currentFilters = {};
  String _searchQuery = '';

  // Mock water monitoring locations data
  final List<Map<String, dynamic>> _waterMonitoringLocations = [
    {
      "id": 1,
      "name": "Central Water Treatment Plant",
      "latitude": 40.7128,
      "longitude": -74.0060,
      "quality": "excellent",
      "ph": 7.2,
      "temperature": 18.5,
      "turbidity": 0.8,
      "dissolvedOxygen": 8.2,
      "lastUpdate": "2 hours ago",
      "dataSource": "Government",
      "hasIssues": false,
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": 2,
      "name": "Riverside Monitoring Station",
      "latitude": 40.7589,
      "longitude": -73.9851,
      "quality": "good",
      "ph": 6.8,
      "temperature": 16.2,
      "turbidity": 1.2,
      "dissolvedOxygen": 7.8,
      "lastUpdate": "4 hours ago",
      "dataSource": "Community",
      "hasIssues": false,
      "timestamp": DateTime.now().subtract(const Duration(hours: 4)),
    },
    {
      "id": 3,
      "name": "Downtown Water Source",
      "latitude": 40.7505,
      "longitude": -73.9934,
      "quality": "moderate",
      "ph": 6.2,
      "temperature": 22.1,
      "turbidity": 2.8,
      "dissolvedOxygen": 6.5,
      "lastUpdate": "6 hours ago",
      "dataSource": "Expert",
      "hasIssues": true,
      "timestamp": DateTime.now().subtract(const Duration(hours: 6)),
    },
    {
      "id": 4,
      "name": "Industrial District Well",
      "latitude": 40.7282,
      "longitude": -74.0776,
      "quality": "poor",
      "ph": 5.8,
      "temperature": 25.3,
      "turbidity": 4.2,
      "dissolvedOxygen": 4.8,
      "lastUpdate": "8 hours ago",
      "dataSource": "Automated",
      "hasIssues": true,
      "timestamp": DateTime.now().subtract(const Duration(hours: 8)),
    },
    {
      "id": 5,
      "name": "Community Center Tap",
      "latitude": 40.7614,
      "longitude": -73.9776,
      "quality": "critical",
      "ph": 4.9,
      "temperature": 28.7,
      "turbidity": 6.8,
      "dissolvedOxygen": 3.2,
      "lastUpdate": "12 hours ago",
      "dataSource": "Community",
      "hasIssues": true,
      "timestamp": DateTime.now().subtract(const Duration(hours: 12)),
    },
    {
      "id": 6,
      "name": "North Side Reservoir",
      "latitude": 40.7831,
      "longitude": -73.9712,
      "quality": "excellent",
      "ph": 7.4,
      "temperature": 17.8,
      "turbidity": 0.6,
      "dissolvedOxygen": 8.8,
      "lastUpdate": "1 hour ago",
      "dataSource": "Government",
      "hasIssues": false,
      "timestamp": DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      "id": 7,
      "name": "East Valley Spring",
      "latitude": 40.7282,
      "longitude": -73.9942,
      "quality": "good",
      "ph": 7.0,
      "temperature": 15.2,
      "turbidity": 1.0,
      "dissolvedOxygen": 8.0,
      "lastUpdate": "3 hours ago",
      "dataSource": "Expert",
      "hasIssues": false,
      "timestamp": DateTime.now().subtract(const Duration(hours: 3)),
    },
    {
      "id": 8,
      "name": "Municipal Water Tower",
      "latitude": 40.7505,
      "longitude": -74.0014,
      "quality": "moderate",
      "ph": 6.5,
      "temperature": 20.5,
      "turbidity": 2.2,
      "dissolvedOxygen": 6.8,
      "lastUpdate": "5 hours ago",
      "dataSource": "Government",
      "hasIssues": false,
      "timestamp": DateTime.now().subtract(const Duration(hours: 5)),
    },
  ];

  List<Map<String, dynamic>> get _filteredLocations {
    List<Map<String, dynamic>> filtered = List.from(_waterMonitoringLocations);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((location) {
        final name = (location['name'] as String).toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply quality level filter
    final qualityLevels = _currentFilters['qualityLevels'] as List<String>?;
    if (qualityLevels != null && qualityLevels.isNotEmpty) {
      filtered = filtered.where((location) {
        final quality = (location['quality'] as String).toLowerCase();
        return qualityLevels.any((level) => level.toLowerCase() == quality);
      }).toList();
    }

    // Apply data source filter
    final dataSources = _currentFilters['dataSources'] as List<String>?;
    if (dataSources != null && dataSources.isNotEmpty) {
      filtered = filtered.where((location) {
        final source = location['dataSource'] as String;
        return dataSources.contains(source);
      }).toList();
    }

    // Apply date range filter
    final startDate = _currentFilters['startDate'] as DateTime?;
    final endDate = _currentFilters['endDate'] as DateTime?;
    if (startDate != null && endDate != null) {
      filtered = filtered.where((location) {
        final timestamp = location['timestamp'] as DateTime;
        return timestamp.isAfter(startDate) &&
            timestamp.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply pH range filter
    final phRange = _currentFilters['phRange'] as RangeValues?;
    if (phRange != null) {
      filtered = filtered.where((location) {
        final ph = location['ph'] as double;
        return ph >= phRange.start && ph <= phRange.end;
      }).toList();
    }

    // Apply temperature range filter
    final tempRange = _currentFilters['temperatureRange'] as RangeValues?;
    if (tempRange != null) {
      filtered = filtered.where((location) {
        final temp = location['temperature'] as double;
        return temp >= tempRange.start && temp <= tempRange.end;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main map area
            _buildMapArea(),

            // Search bar overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: MapSearchBarWidget(
                onSearch: _handleSearch,
                onFilterTap: _showFilterBottomSheet,
              ),
            ),

            // Map controls
            MapControlsWidget(
              onCurrentLocationTap: _centerOnCurrentLocation,
              onLayerToggle: _toggleMapLayer,
              onReportHere: _reportHere,
              isLocationLoading: _isLocationLoading,
              currentLayer: _currentMapLayer,
            ),

            // Marker callout
            if (_showCallout && _selectedMarker.isNotEmpty)
              Positioned(
                bottom: 32.h,
                left: 0,
                right: 0,
                child: MarkerCalloutWidget(
                  markerData: _selectedMarker,
                  onDetailsTap: _openWaterSourceDetails,
                  onClose: _closeCallout,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildMapArea() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: EdgeInsets.only(top: 12.h),
      decoration: BoxDecoration(
        color: _currentMapLayer == 'satellite'
            ? const Color(0xFF2D5016) // Satellite-like green
            : const Color(0xFFF0F8FF), // Light blue for standard
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Stack(
          children: [
            // Map background with grid pattern
            _buildMapBackground(),

            // Water monitoring markers
            ..._buildWaterQualityMarkers(),

            // Current location indicator (mock)
            _buildCurrentLocationIndicator(),

            // Offline indicator
            if (!kIsWeb) _buildOfflineIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: _MapBackgroundPainter(
          isStandard: _currentMapLayer == 'standard',
        ),
      ),
    );
  }

  List<Widget> _buildWaterQualityMarkers() {
    return _filteredLocations.map((location) {
      // Convert lat/lng to screen coordinates (mock positioning)
      final screenX = ((location['longitude'] as double) + 74.1) * 100.w;
      final screenY = (40.8 - (location['latitude'] as double)) * 100.h;

      return Positioned(
        left: screenX.clamp(5.w, 90.w),
        top: screenY.clamp(15.h, 70.h),
        child: WaterQualityMarkerWidget(
          markerData: location,
          isSelected: _selectedMarker['id'] == location['id'],
          onTap: () => _selectMarker(location),
        ),
      );
    }).toList();
  }

  Widget _buildCurrentLocationIndicator() {
    return Positioned(
      left: 45.w,
      top: 40.h,
      child: Container(
        width: 4.w,
        height: 4.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.surface,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 1.w,
            height: 1.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineIndicator() {
    return Positioned(
      top: 2.h,
      left: 4.w,
      child: Container(
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
            CustomIconWidget(
              iconName: 'cloud_done',
              color: AppTheme.excellentWaterQuality,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              'Online',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _showCallout = false;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MapFilterBottomSheetWidget(
        currentFilters: _currentFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _currentFilters = filters;
            _showCallout = false;
          });
        },
      ),
    );
  }

  void _selectMarker(Map<String, dynamic> markerData) {
    setState(() {
      _selectedMarker = markerData;
      _showCallout = true;
    });
  }

  void _closeCallout() {
    setState(() {
      _showCallout = false;
      _selectedMarker = {};
    });
  }

  void _centerOnCurrentLocation() {
    setState(() {
      _isLocationLoading = true;
    });

    // Simulate location loading
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLocationLoading = false;
        });
      }
    });
  }

  void _toggleMapLayer() {
    setState(() {
      _currentMapLayer =
          _currentMapLayer == 'standard' ? 'satellite' : 'standard';
    });
  }

  void _reportHere() {
    Navigator.pushNamed(context, '/water-quality-data-entry-screen');
  }

  void _openWaterSourceDetails() {
    // Navigate to detailed water source screen
    _closeCallout();
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/dashboard-screen');
        break;
      case 1:
        // Already on map screen
        break;
      case 2:
        Navigator.pushNamed(context, '/water-quality-data-entry-screen');
        break;
      case 3:
        Navigator.pushNamed(context, '/analytics-dashboard-screen');
        break;
    }
  }
}

class _MapBackgroundPainter extends CustomPainter {
  final bool isStandard;

  _MapBackgroundPainter({required this.isStandard});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isStandard
          ? const Color(0xFFE3F2FD) // Light blue for water areas
          : const Color(0xFF1B5E20) // Dark green for satellite
      ..style = PaintingStyle.fill;

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw grid lines for map feel
    final gridPaint = Paint()
      ..color = (isStandard ? Colors.blue : Colors.green).withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Vertical lines
    for (double x = 0; x < size.width; x += size.width / 10) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += size.height / 10) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw some mock geographic features
    final featurePaint = Paint()
      ..color = isStandard
          ? const Color(0xFF81C784) // Green for parks
          : const Color(0xFF2E7D32) // Darker green for satellite
      ..style = PaintingStyle.fill;

    // Mock park areas
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.3, size.width * 0.15,
          size.height * 0.1),
      featurePaint,
    );

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.6, size.width * 0.2,
          size.height * 0.15),
      featurePaint,
    );

    // Mock water bodies
    final waterPaint = Paint()
      ..color = isStandard
          ? const Color(0xFF42A5F5) // Blue for water
          : const Color(0xFF1565C0) // Darker blue for satellite
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.7, size.height * 0.2, size.width * 0.25,
          size.height * 0.2),
      waterPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
