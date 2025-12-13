import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/token_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  // Skip Firebase on web as it has compatibility issues
  if (!kIsWeb) {
    try {
      // Firebase imports are only available on mobile
      // await Firebase.initializeApp();
      // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      // await NotificationService.initialize();
    } catch (e) {
      print('Firebase initialization failed: $e');
    }
  }
  
  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A0E13),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
  
  runApp(const DexTokenSnifferApp());
}

class DexTokenSnifferApp extends StatelessWidget {
  const DexTokenSnifferApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TokenProvider(),
      child: MaterialApp(
        title: 'DexTokenSniffer PRO',
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
