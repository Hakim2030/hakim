import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const Hakim());
}

class Hakim extends StatelessWidget {
  const Hakim({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'حكيم',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'ThmanyahSerifDisplay',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0C3468),
          primary: const Color(0xFF0C3468),
          surface: Colors.white,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const LoginScreen(),
    );
  }
}
