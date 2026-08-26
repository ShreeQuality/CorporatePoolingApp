import 'dart:io';

void main() {
  final file = File('lib/screens/auth/phone_login_screen.dart');
  String content = file.readAsStringSync();
  
  // Wipe out the corrupted lines entirely using multi-line regex
  content = content.replaceAll(RegExp(r"String _selectedCountryFlag = '.*?';"), "String _selectedCountryFlag = '\\u{1F1EE}\\u{1F1F3}';");
  
  final newCountries = """
  final List<Map<String, dynamic>> _countryCodes = [
    {'name': 'India', 'code': '+91', 'flag': '\\u{1F1EE}\\u{1F1F3}', 'digits': 10},
    {'name': 'United States', 'code': '+1', 'flag': '\\u{1F1FA}\\u{1F1F8}', 'digits': 10},
    {'name': 'United Kingdom', 'code': '+44', 'flag': '\\u{1F1EC}\\u{1F1E7}', 'digits': 10},
    {'name': 'United Arab Emirates', 'code': '+971', 'flag': '\\u{1F1E6}\\u{1F1EA}', 'digits': 9},
    {'name': 'Singapore', 'code': '+65', 'flag': '\\u{1F1F8}\\u{1F1EC}', 'digits': 8},
    {'name': 'Germany', 'code': '+49', 'flag': '\\u{1F1E9}\\u{1F1EA}', 'digits': 10},
    {'name': 'Canada', 'code': '+1', 'flag': '\\u{1F1E8}\\u{1F1E6}', 'digits': 10},
    {'name': 'Australia', 'code': '+61', 'flag': '\\u{1F1E6}\\u{1F1FA}', 'digits': 9},
    {'name': 'Netherlands', 'code': '+31', 'flag': '\\u{1F1F3}\\u{1F1F1}', 'digits': 9},
    {'name': 'France', 'code': '+33', 'flag': '\\u{1F1EB}\\u{1F1F7}', 'digits': 9},
    {'name': 'Japan', 'code': '+81', 'flag': '\\u{1F1EF}\\u{1F1F5}', 'digits': 10},
  ];
""";

  content = content.replaceAll(RegExp(r"final List<Map<String, dynamic>> _countryCodes = \[.*?\];", multiLine: true, dotAll: true), newCountries);

  // Also strip all the non-ascii comment headers
  content = content.replaceAll(RegExp(r"// [^\x00-\x7F]+ .*?[^\x00-\x7F]+\n"), "\n");
  
  file.writeAsStringSync(content);
}
