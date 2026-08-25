import 'dart:io';

void main() {
  final file = File('lib/screens/auth/onboarding_screen.dart');
  String content = file.readAsStringSync();
  
  final target = '''
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PhoneLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
''';
  
  final replacement = '''
    if (!mounted) return;
    context.go('/phone-login');
''';

  content = content.replaceAll(target, replacement);
  file.writeAsStringSync(content);
}
