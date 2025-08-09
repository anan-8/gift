import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gift/Checkout_Screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gift/Splash_Screen.dart';
import 'package:gift/User_Settings_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routes: {
        '/checkout': (context) => CheckoutScreen(),
        '/settings': (context) => UserSettingsScreen(
          isLoggedIn: FirebaseAuth.instance.currentUser != null,
        ),
      },

      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
