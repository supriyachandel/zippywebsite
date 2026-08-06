import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user_state.dart';
import 'models/cart_state.dart';
import 'services/api_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/tracking_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.loadToken();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserState()),
        ChangeNotifierProvider(create: (context) => CartState()),
      ],
      child: const ThStyleApp(),
    ),
  );
}

class ThStyleApp extends StatelessWidget {
  const ThStyleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
      builder: (context, userState, child) {
        return MaterialApp(
          title: 'thStyle',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(userState.gender),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/auth': (context) => const AuthScreen(),
            '/home': (context) => const HomeScreen(),
            '/tracking': (context) => const TrackingScreen(),
          },
        );
      },
    );
  }
}
