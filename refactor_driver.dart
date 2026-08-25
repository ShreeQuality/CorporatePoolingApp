import 'dart:io';

void main() {
  final file = File('lib/screens/auth/driver_kyc_screen.dart');
  if (!file.existsSync()) return;
  String content = file.readAsStringSync();
  
  // ensure go_router is imported
  if (!content.contains("import 'package:go_router/go_router.dart';")) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:go_router/go_router.dart';");
  }
  
  final regexNamedArgs = RegExp(r"Navigator\.of\(context\)\.pushNamedAndRemoveUntil\([\s\S]*?'/home',[\s\S]*?\(route\) => false,[\s\S]*?arguments: (\{[^\}]+\}),[\s\S]*?\);");
  content = content.replaceAllMapped(regexNamedArgs, (match) {
    return "context.go('/home', extra: );";
  });
  
  final regexNamed = RegExp(r"Navigator\.of\(context\)\.pushNamedAndRemoveUntil\([\s\S]*?'/home',[\s\S]*?\(route\) => false[\s\S]*?\);");
  content = content.replaceAll(regexNamed, "context.go('/home');");
  
  file.writeAsStringSync(content);
}
