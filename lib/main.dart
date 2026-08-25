import 'package:flutter/material.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/dashboard/home_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KarmaRideApp());
}

class KarmaRideApp extends StatelessWidget {
  const KarmaRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KarmaRide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF070B19),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return HomeDashboard(arguments: args);
        },
      },
    );
  }
}
