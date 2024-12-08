import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tng/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vcwvnywuharrcndnhrjm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZjd3ZueXd1aGFycmNuZG5ocmptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM1Nzc1MzQsImV4cCI6MjA0OTE1MzUzNH0.VPPCc_JS0tk7vGYM6Rfu0OTFbAdsYqs47SRJOmhxlmg',
  );
  // FlutterStatusbarcolor.setStatusBarColor(const Color(0xff005abe));

  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   systemNavigationBarColor: Colors.blue, // navigation bar color
  //   statusBarColor: Color(
  //     0xff005abe,
  //   ), // status bar color
  // ));
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(
            0xff005abe,
          ),
        ),
        // textTheme: GoogleFonts.openSansTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(
            0xff005abe,
          ),
          // titleTextStyle: TextStyle(color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
      builder: EasyLoading.init(),
    );
  }
}
