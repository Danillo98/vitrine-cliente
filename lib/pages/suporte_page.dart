import 'package:flutter/material.dart';
import '../componentes/side_menu.dart';

class SuportePage extends StatefulWidget {
  const SuportePage({Key? key}) : super(key: key);

  @override
  State<SuportePage> createState() => _SuportePageState();
}

class _SuportePageState extends State<SuportePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
        }),
        title: Text(
          'Escolha um contato:',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/background5.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.7), // ajuste a opacidade conforme necessário
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset("images/LogoVitrine2.png"),
                ),
                const SizedBox(height: 30),
                Card(
                  color: Colors.white.withOpacity(0.7),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Telefones:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '(22) 99878-6284\n(22) 99282-3204',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'E-mails:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'danilloneto98@gmail.com\ngabrielmoreirafonseca97@gmail.com',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
