import 'package:flutter/material.dart';
import 'pages/inicio_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => InicioScreen()),
      );
    });
  }
//Widget para retornar a imagem da tela de carregamento (SplashScreen)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF22293E),
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}