import 'dart:io';

void main() {
  final file = File('lib/screens/auth/onboarding_screen.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceAll("import 'phone_login_screen.dart';", "import 'package:go_router/go_router.dart';");
  
  final regex = RegExp(r"Navigator\.pushReplacement\([\s\S]*?PhoneLoginScreen\(\)[\s\S]*?\);");
  content = content.replaceAll(regex, "context.go('/phone-login');");
  
  // Also, in onboarding_screen, previously I removed a SnackBar and replaced it with PushReplacement.
  // Wait, I am currently at fa9f939. Let's see what it has.
  file.writeAsStringSync(content);
}
