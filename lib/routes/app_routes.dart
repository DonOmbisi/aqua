import 'package:flutter/material.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/map_view_screen/map_view_screen.dart';
import '../presentation/analytics_dashboard_screen/analytics_dashboard_screen.dart';
import '../presentation/water_quality_data_entry_screen/water_quality_data_entry_screen.dart';

class AppRoutes {
  // Main application routes
  static const String initial = '/';
  static const String loginScreen = '/login-screen';
  static const String registrationScreen = '/registration-screen';
  static const String dashboardScreen = '/dashboard-screen';
  static const String waterQualityDataEntryScreen =
      '/water-quality-data-entry-screen';
  static const String mapViewScreen = '/map-view-screen';
  static const String analyticsDashboardScreen = '/analytics-dashboard-screen';

  /// Route definitions for the Aqua Horizon water monitoring application
  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    loginScreen: (context) => const LoginScreen(),
    registrationScreen: (context) => const RegistrationScreen(),
    dashboardScreen: (context) => const DashboardScreen(),
    waterQualityDataEntryScreen: (context) =>
        const WaterQualityDataEntryScreen(),
    mapViewScreen: (context) => const MapViewScreen(),
    analyticsDashboardScreen: (context) => const AnalyticsDashboardScreen(),
  };

  /// Get all available route names
  static List<String> get allRoutes => [
        initial,
        loginScreen,
        registrationScreen,
        dashboardScreen,
        waterQualityDataEntryScreen,
        mapViewScreen,
        analyticsDashboardScreen,
      ];

  /// Check if a route exists
  static bool routeExists(String routeName) {
    return routes.containsKey(routeName);
  }
}
