import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vitrine/componentes/side_menu.dart';
import 'package:vitrine/pages/loading_page.dart';
import 'package:vitrine/pages/login_page.dart';
import 'package:vitrine/pages/perfil_page.dart';
import 'package:vitrine/pages/splashScreen.dart';
import 'package:vitrine/pages/suporte_page.dart';


// APP DE CLIENTE - Vitrine
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Garante a inicialização do Firebase antes de rodar o app
  print("Firebase inicializado com sucesso!");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MaterialColor blackSwatch = MaterialColor(
      0xFF000000, 
      <int, Color>{
        50: Color(0xFF000000),
        100: Color(0xFF000000),
        200: Color(0xFF000000),
        300: Color(0xFF000000),
        400: Color(0xFF000000),
        500: Color(0xFF000000),
        600: Color(0xFF000000),
        700: Color(0xFF000000),
        800: Color(0xFF000000),
        900: Color(0xFF000000),
      },
    );

    return MaterialApp(
      title: 'Vitrine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: blackSwatch,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: blackSwatch,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
            textStyle: const TextStyle(
              fontSize: 24.0,
            ),
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 46.0,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          bodyLarge: const TextStyle(fontSize: 20),
        ),
      ),
      home:  SplashScreen(),
    );
  }
}
