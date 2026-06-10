import 'package:backend/screens/forgot_password_screen.dart';
import 'package:backend/screens/login_screen.dart';
import 'package:backend/screens/main_screen.dart';
import 'package:backend/screens/signup_screen.dart';
import 'package:backend/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:backend/screens/shop_screen.dart';
import 'package:backend/screens/Favorites_screen.dart';
import 'package:backend/screens/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ApiService.init();
  runApp(const BackendApp());
}

class BackendApp extends StatelessWidget {
  const BackendApp({super.key, this.authService = const ApiAuthService()});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFDB3022)),
        useMaterial3: false,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginScreen(authService: authService),
        '/signup': (_) => SignUpScreen(authService: authService),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/main': (_) => const MainScreen(),
        '/shop': (_) => const ShopScreen(),
        '/favorites': (_) => const FavoritesScreen(),
      },
    );
  }
}
