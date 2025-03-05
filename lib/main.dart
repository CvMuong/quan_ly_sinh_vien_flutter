import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:quan_ly_diem/controllers/updateStudentInfoController.dart';
import 'package:quan_ly_diem/views/MyApp.dart';
import 'package:quan_ly_diem/views/LoginScreen.dart';
import 'package:quan_ly_diem/views/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);

  Get.put(InfoStudentController());

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

