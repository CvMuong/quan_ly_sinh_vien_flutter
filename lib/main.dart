import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quan_ly_diem/views/MyApp.dart';
import 'package:quan_ly_diem/views/LoginScreen.dart';
import 'package:quan_ly_diem/views/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

