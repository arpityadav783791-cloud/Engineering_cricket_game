import 'package:flutter/material.dart';

import 'controllers/game_controller.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
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
      title: 'Hand Cricket',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
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