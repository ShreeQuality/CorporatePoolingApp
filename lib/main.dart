import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'core/router/app_router.dart';
import 'widgets/core/app_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();
  runApp(const KarmaRideApp());
}

class KarmaRideApp extends StatelessWidget {
  const KarmaRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        title: 'KarmaRide',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF070B19),
        ),
        builder: (context, child) {
          return AppBackground(
            child: child ?? const SizedBox(),
          );
        },
        routerConfig: appRouter,
      ),
    );
  }
}
