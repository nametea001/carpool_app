import 'package:car_pool_project/screens/login_screen.dart';
import 'package:car_pool_project/services/config_system.dart';
import 'package:flutter/material.dart';
import 'package:car_pool_project/global.dart' as globals;

Future<void> main() async {
  runApp(const MyApp());
  globals.serverIP = await ConfigSystem.getServer();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: LoginScreen());
  }
}
