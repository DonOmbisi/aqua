import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:hive_flutter/hive_flutter.dart';

import './routes/app_routes.dart';
import './utils/supabase_service.dart';
import './services/offline_supabase_service.dart';
import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Supabase
  try {
    SupabaseService();
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
  }

  // Initialize offline services
  try {
    final offlineService = OfflineSupabaseService();
    await offlineService.initialize();
    debugPrint('Offline services initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize offline services: $e');
    // Continue anyway - app can still work with just online functionality
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: MaterialApp(
            title: 'Aqua Horizon',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(),
            initialRoute: AppRoutes.loginScreen,
            routes: AppRoutes.routes,
          ),
        );
      },
    );
  }
}