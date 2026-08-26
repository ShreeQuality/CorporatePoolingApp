import 'dart:io';

void main() {
  final file = File('lib/screens/auth/splash_screen.dart');
  String content = file.readAsStringSync();
  
  // Fix 2: The dynamic label bullet
  final dynamicLabelRegex = RegExp(r"'\$\\{_vibrationPatterns\\[_selectedVariationIndex\\]\['label'\]\\} [^']+\\$\\{_vibrationPatterns\\[_selectedVariationIndex\\]\['name'\]\\}'", multiLine: true, dotAll: true);
  content = content.replaceAll(dynamicLabelRegex, "'\$\\{_vibrationPatterns[_selectedVariationIndex]['label']} \\u2022 \$\\{_vibrationPatterns[_selectedVariationIndex]['name']}'");
  
  // Actually, I'll just do a hard replace
  content = content.replaceFirst("['label']} A,A \n\ \\u2022 \ ? \ \\u2022 \ A,A \n\ \\u2022 \ â€¢ \ \\u2022 \
