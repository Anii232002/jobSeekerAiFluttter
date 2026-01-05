import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'providers/job_provider.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/secure_storage_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. Check if user is logged in
      final userId = await SecureStorageService.getUserId();
      if (userId == null) return true;

      // 2. Fetch notifications from API
      final notifications = await ApiService.getNotifications(userId);

      if (notifications.isNotEmpty) {
        // 3. Show local notification for the latest one
        final notification = notifications.first;
        final notificationService = NotificationService();
        await notificationService.init();
        await notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: notification['title'] ?? 'New Job Match',
          body: notification['message'] ?? 'Check out your latest job matches!',
        );
      }
      return true;
    } catch (e) {
      debugPrint("Background task error: $e");
      return false;
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await NotificationService().requestPermissions();

  // Initialize Workmanager
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Calculate delay until next 9:00 AM
  final now = DateTime.now();
  var nextNineAm = DateTime(now.year, now.month, now.day, 9, 0);
  if (now.isAfter(nextNineAm)) {
    nextNineAm = nextNineAm.add(const Duration(days: 1));
  }
  final initialDelay = nextNineAm.difference(now);

  // Register the daily task
  await Workmanager().registerPeriodicTask(
    "daily_job_notification",
    "fetch_notifications_task",
    frequency: const Duration(hours: 24),
    initialDelay: initialDelay,
    constraints: Constraints(networkType: NetworkType.connected),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => JobProvider(),
      child: MaterialApp(
        title: 'Job Finder AI',
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = await SecureStorageService.isLoggedIn();
    if (isLoggedIn && mounted) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await jobProvider.restoreUserFromStorage();
    }

    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryYellow),
        ),
      );
    }

    return _isLoggedIn ? const MainScreen() : const LoginScreen();
  }
}
