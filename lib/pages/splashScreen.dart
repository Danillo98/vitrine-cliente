import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vitrine/principal.dart';
import 'login_page.dart'; // Importa a tela de Login

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();  // Verifica o login ao iniciar a tela
  }

  Future<void> _checkUserLoggedIn() async {
    try {
      // Simula um atraso para exibir a splash por 2 segundos
      await Future.delayed(Duration(seconds: 2));

      // Verifica se o usuário está logado
      User? user = FirebaseAuth.instance.currentUser;

      // Verifica se o usuário está logado e navega para a tela correta
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Principal()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      print("Erro ao verificar login: $e");
      // Opcional: navegar para a tela de erro, ou refazer a tentativa de login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Exibe um indicador enquanto verifica o login
      ),
    );
  }
}
