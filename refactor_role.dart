import 'dart:io';

void main() {
  final file = File('lib/screens/auth/role_selection_screen.dart');
  if (!file.existsSync()) return;
  String content = file.readAsStringSync();
  
  content = content.replaceAll("import 'corporate_verify_screen.dart';", "import 'package:go_router/go_router.dart';");
  
  final regex = RegExp(r"Navigator\.push\([\s\S]*?CorporateVerifyScreen\(\)[\s\S]*?\);");
  content = content.replaceAll(regex, "context.push('/corporate-verify');");
  
  final regexReplacement = RegExp(r"Navigator\.pushReplacement\([\s\S]*?CorporateVerifyScreen\(\)[\s\S]*?\);");
  content = content.replaceAll(regexReplacement, "context.go('/corporate-verify');");
  
  final regexOf = RegExp(r"Navigator\.of\(context\)\.push\([\s\S]*?CorporateVerifyScreen\(\)[\s\S]*?\);");
  content = content.replaceAll(regexOf, "context.push('/corporate-verify');");
  
  final regexOfRep = RegExp(r"Navigator\.of\(context\)\.pushReplacement\([\s\S]*?CorporateVerifyScreen\(\)[\s\S]*?\);");
  content = content.replaceAll(regexOfRep, "context.go('/corporate-verify');");
  
  file.writeAsStringSync(content);
}
