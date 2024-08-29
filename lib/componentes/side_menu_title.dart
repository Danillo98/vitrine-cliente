import 'package:flutter/material.dart';
import 'package:vitrine/database.dart';
import 'package:vitrine/pages/favoritas_page.dart';
import 'package:vitrine/pages/reservas_page.dart';
import 'package:vitrine/pages/suporte_page.dart'; 
import 'package:flutter/services.dart';

class SideMenuTitle extends StatelessWidget {
  final String? userId;
  final Database? db;
  final List<Map<String, dynamic>> reservas; 

  SideMenuTitle({
    Key? key,
    this.userId,
    this.db,
    required this.reservas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Divider(
            color: Colors.white54,
            height: 1,
          ),
        ),
        GestureDetector(
          child: ListTile(
            onTap: () {
              Navigator.pop(context);
            },
            leading: SizedBox(
              height: 34,
              width: 34,
              child: Image.asset(
                "images/btnhome.png",
              ),
            ),
            title: const Text(
              "Home",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Divider(
            color: Colors.white12,
            height: 1,
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FavoritasPage(), // Use SuportePage aqui
              ),
            );
          },
          leading: SizedBox(
            height: 34,
            width: 34,
            child: Image.asset(
              "images/btndiamante.png",
            ),
          ),
          title: const Text(
            "Favoritas",
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Divider(
            color: Colors.white12,
            height: 1,
          ),
        ),
        

        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Divider(
            color: Colors.white12,
            height: 1,
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SuportePage(), // Use SuportePage aqui
              ),
            );
          },
          leading: SizedBox(
            height: 34,
            width: 34,
            child: Image.asset(
              "images/btnsuporte.png",
            ),
          ),
          title: const Text(
            "Suporte",
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Divider(
            color: Colors.white12,
            height: 1,
          ),
        ),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Deseja realmente sair?"),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancelar", style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      child: const Text("Sair", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                );
              },
            );
          },
          child: ListTile(
            leading: SizedBox(
              height: 34,
              width: 34,
              child: Image.asset(
                "images/btnsair.png",
              ),
            ),
            title: const Text(
              "Sair",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ),
        ),
      ],
    );
  }
}
