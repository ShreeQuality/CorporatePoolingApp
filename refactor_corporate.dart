import 'dart:io';

void main() {
  final file = File('lib/screens/auth/corporate_verify_screen.dart');
  if (!file.existsSync()) return;
  String content = file.readAsStringSync();
  
  content = content.replaceAll("import 'aadhaar_kyc_screen.dart';", "import 'package:go_router/go_router.dart';");
  
  final regex = RegExp(r"Navigator\.push\([\s\S]*?AadhaarKycScreen\(\)[\s\S]*?\);");
  content = content.replaceAll(regex, "context.push('/aadhaar-kyc');");
  
  final regexReplacement = RegExp(r"Navigator\.pushReplacement\([\s\S]*?AadhaarKycScreen\(\)[\s\S]*?\);");
  content = content.replaceAll(regexReplacement, "context.go('/aadhaar-kyc');");
  
  final regexOf = RegExp(r"Navigator\.of\(context\)\.push\([\s\S]*?AadhaarKycScreen\(\)[\s\S]*?\);");
  content = content.replaceAll(regexOf, "context.push('/aadhaar-kyc');");
  
  final regexOfRep = RegExp(r"Navigator\.of\(context\)\.pushReplacement\([\s\S]*?AadhaarKycScreen\(\)[\s\S]*?\);");
  content = content.replaceAll(regexOfRep, "context.go('/aadhaar-kyc');");
  
  file.writeAsStringSync(content);
}
