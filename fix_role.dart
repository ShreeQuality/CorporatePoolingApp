import 'dart:io';

void main() {
  final file = File('lib/screens/auth/role_selection_screen.dart');
  String content = file.readAsStringSync();
  
  final regex = RegExp(r"Navigator\.of\(context\)\.pushReplacement\([\s\S]*?MaterialPageRoute\([\s\S]*?builder: \(context\) => CorporateVerifyScreen\([\s\S]*?preselectedRole: _selectedRole == 'company' \? 'corporate_employee' : 'public_user',[\s\S]*?\),[\s\S]*?\),[\s\S]*?\);");
  content = content.replaceAll(regex, "context.go('/corporate-verify', extra: {'preselectedRole': _selectedRole == 'company' ? 'corporate_employee' : 'public_user'});");
  
  file.writeAsStringSync(content);
}
