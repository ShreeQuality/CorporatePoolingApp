import 'dart:io';

void main() {
  final file = File('lib/screens/auth/phone_login_screen.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceAll("import 'role_selection_screen.dart';", "import 'package:go_router/go_router.dart';");
  
  final regex = RegExp(r"Navigator\.of\(context\)\.pushReplacement\([\s\S]*?RoleSelectionScreen\(\)[\s\S]*?\);");
  content = content.replaceAll(regex, "context.go('/role-selection');");
  
  final regexPush = RegExp(r"Navigator\.pushReplacement\([\s\S]*?RoleSelectionScreen\(\)[\s\S]*?\);");
  content = content.replaceAll(regexPush, "context.go('/role-selection');");
  
  file.writeAsStringSync(content);
}
