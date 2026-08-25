import 'dart:io';

void main() {
  final file = File('lib/screens/auth/corporate_verify_screen.dart');
  String content = file.readAsStringSync();
  
  final regex1 = RegExp(r"Navigator\.of\(context\)\.pushReplacement\([\s\S]*?MaterialPageRoute\([\s\S]*?builder: \(context\) => AadhaarKycScreen\(previousPayload: payload\),[\s\S]*?\),[\s\S]*?\);");
  content = content.replaceAll(regex1, "context.go('/aadhaar-kyc', extra: payload);");
  
  final regex2 = RegExp(r"Navigator\.of\(context\)\.pushReplacement\([\s\S]*?MaterialPageRoute\([\s\S]*?builder: \(context\) => AadhaarKycScreen\(previousPayload: publicPayload\),[\s\S]*?\),[\s\S]*?\);");
  content = content.replaceAll(regex2, "context.go('/aadhaar-kyc', extra: publicPayload);");

  file.writeAsStringSync(content);
}
