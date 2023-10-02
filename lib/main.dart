import 'package:flutter/material.dart';
import 'package:tng/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterStatusbarcolor.setStatusBarColor(const Color(0xff1f5bc1));

  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.blue, // navigation bar color
  //   statusBarColor: Color(
  //     0xff1f5bc1,
  //   ), // status bar color
  // ));
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(
            0xff1f5bc1,
          ),
        ),
        // textTheme: GoogleFonts.openSansTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}
