import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'providers/job_provider.dart';
import 'theme/app_theme.dart';
import 'services/secure_storage_service.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await NotificationService().requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Widget> _getHomeScreen() async {
    final isLoggedIn = await SecureStorageService.isLoggedIn();
    if (isLoggedIn) {
      // Restore user data from secure storage
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await jobProvider.restoreUserFromStorage();
      return const MainScreen();
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => JobProvider(),
      child: MaterialApp(
        title: 'Job Finder AI',
        theme: AppTheme.darkTheme,
        home: FutureBuilder<Widget>(
          future: _getHomeScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
                body: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryYellow,
                  ),
                ),
              );
            }
            return snapshot.data ?? const LoginScreen();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
