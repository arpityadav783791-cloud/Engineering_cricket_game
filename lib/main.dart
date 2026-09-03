import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controllers/game_controller.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI to immersive dark styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF040B1E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await AudioService.instance.init();

  runApp(const HandCricketApp());
}

class HandCricketApp extends StatefulWidget {
  const HandCricketApp({super.key});

  @override
  State<HandCricketApp> createState() => _HandCricketAppState();
}

class _HandCricketAppState extends State<HandCricketApp> {
  late final GameController gameController;

  @override
  void initState() {
    super.initState();
    gameController = GameController();
    gameController.loadMatchHistory();
  }

  @override
  void dispose() {
    gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hand Cricket - Finger Challenge',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF040B1E),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFF76FF03),
          surface: Color(0xFF0C1735),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => HomeScreen(
              gameController: gameController,
            ),
      },
    );
  }
}