import 'dart:io';

void main() {
  final file = File('lib/screens/auth/splash_screen.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceAll("import 'onboarding_screen.dart';", "import 'package:go_router/go_router.dart';");
  
  // Find the exact pushReplacement string
  final regex = RegExp(r"Navigator\.of\(context\)\.pushReplacement\([\s\S]*?OnboardingScreen\(\)[\s\S]*?\);");
  content = content.replaceAll(regex, "context.go('/onboarding');");
  
  file.writeAsStringSync(content);
}
