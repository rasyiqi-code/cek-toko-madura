import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/stock_provider.dart';
import 'providers/trial_provider.dart';
import 'screens/license_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StockProvider(prefs)),
        ChangeNotifierProvider(create: (_) => TrialProvider(prefs)),
      ],
      child: const MaduraStockApp(),
    ),
  );
}

class MaduraStockApp extends StatelessWidget {
  const MaduraStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audit Toko Madura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFFD32F2F),
        cardTheme: const CardThemeData(
          color: Color(0xFFD32F2F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          elevation: 0,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0A0A0A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD32F2F),
          secondary: Color(0xFFFF5252),
          surface: Color(0xFFD32F2F),
          onSurface: Colors.white,
          onPrimary: Colors.white,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: Consumer<TrialProvider>(
        builder: (context, trial, child) {
          if (trial.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (trial.isLicensed || trial.isTrialActive) {
            return Consumer<StockProvider>(
              builder: (context, stock, _) {
                if (!stock.isInitialized) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (stock.currentUser == null) return const LoginScreen();
                return const HomeScreen();
              },
            );
          }
          return const LicenseScreen();
        },
      ),
    );
  }
}
