import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();
  runApp(const CorporatePoolingApp());
}

class CorporatePoolingApp extends StatelessWidget {
  const CorporatePoolingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'KarmaRide',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const WelcomeScreen(),
      ),
    );
  }
}
