import 'dart:io';

void main() {
  final file = File('lib/screens/auth/aadhaar_kyc_screen.dart');
  if (!file.existsSync()) return;
  String content = file.readAsStringSync();
  
  content = content.replaceAll("import 'driver_kyc_screen.dart';", "import 'package:go_router/go_router.dart';");
  
  final regex = RegExp(r"Navigator\.of\(context\)\.pushReplacement\([\s\S]*?DriverKycScreen\([\s\S]*?verifiedAadhaarProfile: profile,[\s\S]*?\),[\s\S]*?\),[\s\S]*?\);");
  content = content.replaceAll(regex, "context.go('/driver-kyc', extra: profile);");
  
  file.writeAsStringSync(content);
}
