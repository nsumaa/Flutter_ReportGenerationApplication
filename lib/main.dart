import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'login.dart';
import 'register.dart';
import 'appbody.dart';

// void main(){
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     initialRoute:'login',
//      routes: {
//        'login':(context)=>MyLogin(),
//        'register':(context)=>MyRegister(),
//        'appbody': (context) => CameraApp(),
//      },
//   ));
// }
void main() async {
  // Initialize the cameras
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'login',
    routes: {
      'login': (context) => MyLogin(),
      'register': (context) => MyRegister(),
      'appbody': (context) => CameraApp(cameras: cameras), // Pass cameras to CameraApp
    },
  ));
}