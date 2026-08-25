import 'dart:io';

void main() {
  final file = File('lib/screens/auth/onboarding_screen.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceAll('Ã°Å¸â€ â€™', '✅');
  content = content.replaceAll('Ã°Å¸Â Â¢', '🏢');
  content = content.replaceAll('Ã°Å¸Å¡Â¨', '🚨');
  content = content.replaceAll('Ã¢Å¡Â¡', '⚡');
  content = content.replaceAll('Ã°Å¸â€œÂ¡', '📶');
  content = content.replaceAll('Ã°Å¸Âªâ„¢', '🪙');
  content = content.replaceAll('COÃ¢â€šâ€š', 'CO₂');
  content = content.replaceAll('Ã¢âºÂ½', '⛽');
  content = content.replaceAll('Ã°Å¸Å’Â±', '🌱');
  content = content.replaceAll('Ã°Å¸Â â€', '🏆');
  // Check for the dashed line artifacts
  content = content.replaceAll('Ã¢â‚¬â€œÃ¢â‚¬â€œÃ¢â‚¬â€œ', '---');
  content = content.replaceAll('Ã¢â‚¬Â¢', '•');
  
  file.writeAsStringSync(content);
  print('Done fixing onboarding_screen');
}
