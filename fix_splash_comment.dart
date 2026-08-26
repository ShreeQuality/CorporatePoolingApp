import 'dart:io';

void main() {
  final file = File('lib/screens/auth/splash_screen.dart');
  String content = file.readAsStringSync();
  content = content.replaceAll(RegExp(r"// Other versions .*? imported"), "// Other versions (v1, v3-v10, newsudarshan) kept as files in /widgets but NOT imported");
  file.writeAsStringSync(content);
}
