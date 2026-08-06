import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/cart_state.dart';
import 'models/user_state.dart';
import 'utils/app_theme.dart';
import 'store_side/screens/store_home_screen.dart';
import 'store_side/screens/store_auth_screen.dart';
import 'store_side/services/store_api_service.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StoreApiService.loadToken();
  await StoreApiService.loadShopId();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => CartState()),
      ],
      child: const StoreApp(),
    ),
  );
}

class StoreApp extends StatelessWidget {
  const StoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'thStyle Seller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.offWhite,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryDark,
          secondary: AppColors.primaryBlue,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StoreSplashScreen(),
        '/store_auth': (context) => const StoreAuthScreen(),
        '/store_home': (context) => const StoreHomeScreen(),
      },
    );
  }
}

class StoreSplashScreen extends StatefulWidget {
  const StoreSplashScreen({super.key});

  @override
  State<StoreSplashScreen> createState() => _StoreSplashScreenState();
}

class _StoreSplashScreenState extends State<StoreSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    await context.read<CartState>().init();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final hasToken = StoreApiService.token != null && StoreApiService.token!.isNotEmpty;
    final hasShop = StoreApiService.shopId != null && StoreApiService.shopId! > 0;

    if (hasToken && hasShop) {
      Navigator.pushReplacementNamed(context, '/store_home');
    } else {
      Navigator.pushReplacementNamed(context, '/store_auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 90, height: 90),
            const SizedBox(height: 24),
            Text(
              "THSTYLE",
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "SELLER",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: AppColors.primaryDark.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
