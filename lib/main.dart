import 'package:flutter/material.dart';
import 'package:my_first_real_app/pages/splash_screen.dart';
import 'package:my_first_real_app/pages/home_page.dart';
import 'package:my_first_real_app/pages/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Mostrar la SplashScreen al inicio
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF006847), // Verde de la bandera de México
                Color(0xFFFFFFFF), // Blanco de la bandera de México
                Color(0xFFCE1126), // Rojo de la bandera de México
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: child, // Mostrar el contenido de la aplicación
        );
      },
    );
  }
}