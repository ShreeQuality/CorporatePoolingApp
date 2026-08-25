import 'dart:io';

void main() {
  final file = File('lib/screens/auth/onboarding_screen.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceAll(RegExp(r'[^\x00-\x7F]+ Work Email Verified'), '✅ Work Email Verified');
  content = content.replaceAll(RegExp(r'[^\x00-\x7F]+ Tech Park Network'), '🏢 Tech Park Network');
  content = content.replaceAll(RegExp(r'[^\x00-\x7F]+ 30,000\+ Fuel Pumps'), '⛽ 30,000+ Fuel Pumps');
  content = content.replaceAll(RegExp(r'[^\x00-\x7F]+ Green Leaderboards'), '🏆 Green Leaderboards');
  
  // For comments, let's just replace any sequence of non-ascii characters with '---'
  // But be careful not to mess up anything else.
  content = content.replaceAll(RegExp(r'// [^\x00-\x7F]+ \[RAIN 1\]'), '// --- [RAIN 1]');
  content = content.replaceAll(RegExp(r'[^\x00-\x7F]+ \[RAIN 1\]:'), '--- [RAIN 1]:');
  
  file.writeAsStringSync(content);
  print('Regex replacements done');
}
