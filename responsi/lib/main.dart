import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screen/login_screen.dart';
import 'screen/product_screen.dart';
import 'service/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await DatabaseService.init();

  final isLogin = DatabaseService.isLoggedIn();
  final savedUsername = DatabaseService.getSessionUsername();

  runApp(MainApp(
    isLogin: isLogin && savedUsername.isNotEmpty,
    username: savedUsername,
  ));
}

class MainApp extends StatelessWidget {
  final bool isLogin;
  final String username;

  const MainApp({
    super.key,
    required this.isLogin,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShoppingHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          primary: Colors.orange,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: isLogin ? ProductScreen(username: username) : const LoginScreen(),
    );
  }
}
