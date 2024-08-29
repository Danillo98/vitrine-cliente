import 'package:firebase_storage/firebase_storage.dart' as firebase_storage; // Adicione o prefixo 'firebase_storage'
import 'package:flutter/material.dart';
import 'package:vitrine/database.dart';
import 'side_menu_title.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:vitrine/pages/reservas_page.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool _isLoading = false;
  String? _imagePath;
  String? _clienteNome;
  late String _userId;
  Database? db;
  List<Map<String, dynamic>> _reservas = []; // Adicione uma lista de reservas aqui

 @override
void initState() {
  super.initState();
  _initUserId();
  _loadReservas(); // Carregar reservas quando o usuário estiver autenticado
}



  Future<void> _initUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('Usuário autenticado: ${user.uid}');
      setState(() {
        _userId = user.uid;
        _loadClienteNome();
        _loadImagePath();
        _loadReservas(); // Carregue as reservas quando o usuário estiver autenticado
      });
    } else {
      print('Usuário não autenticado');
    }
  }

  Future<void> _loadClienteNome() async {
    if (_clienteNome == null) {
      CollectionReference clientes =
          FirebaseFirestore.instance.collection('userscliente');

      try {
        // Obtém o documento do cliente associada ao usuário autenticado
        DocumentSnapshot clienteDoc = await clientes.doc(_userId).get();

        if (clienteDoc.exists) {
          setState(() {
            _clienteNome = clienteDoc['nome'];
          });
        }
      } catch (e) {
        print('Erro ao carregar o nome do cliente: $e');
      }
    }
  }

  Future<void> _loadImagePath() async {
    CollectionReference clientes =
        FirebaseFirestore.instance.collection('userscliente');

    try {
      DocumentSnapshot clienteDoc = await clientes.doc(_userId).get();

      if (clienteDoc.exists) {
        setState(() {
          _imagePath = clienteDoc['profileImage'];
        });
      }
    } catch (e) {
      print('Erro ao carregar o caminho da imagem: $e');
    }
  }

  Future<void> _saveImagePath(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('image_path_$_userId', imagePath);
  }

  Future<void> _uploadImage(ImageSource source) async {
    setState(() {
      _isLoading = true; // Inicia o indicador de carregamento
    });

    try {
      ImagePicker imagePicker = ImagePicker();
      XFile? file = await imagePicker.pickImage(source: source);

      if (file == null) {
        setState(() {
          _isLoading = false; // Para o indicador se o arquivo for nulo
        });
        return;
      }

      String uniqueFileName = '$_userId${DateTime.now().millisecondsSinceEpoch}';

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images/$uniqueFileName');

      firebase_storage.UploadTask uploadTask = ref.putFile(File(file.path));
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;

      if (taskSnapshot.state == firebase_storage.TaskState.success) {
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('userscliente')
            .doc(_userId)
            .update({
          'profileImage': imageUrl,
        });

        await _saveImagePath(imageUrl);

        setState(() {
          _imagePath = imageUrl;
        });
      }
    } catch (e) {
      // Trate erros aqui, se necessário
    } finally {
      setState(() {
        _isLoading = false; // Para o indicador de carregamento
      });
    }
  }

Future<void> _showImageChangeDialog() async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Alterar Imagem de Perfil'),
        content: const Text('Você deseja alterar sua imagem de perfil?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Alterar', style: TextStyle(color: Colors.black)),
            onPressed: () {
              _uploadImage(ImageSource.gallery); // Chame o método de upload da imagem
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  Future<void> _loadReservas() async {
    CollectionReference reservasRef =
        FirebaseFirestore.instance.collection('reservas');

    try {
      QuerySnapshot querySnapshot = await reservasRef
          .where('userId', isEqualTo: _userId)
          .get();

      List<Map<String, dynamic>> reservas = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        _reservas = reservas;
      });
    } catch (e) {
      print('Erro ao carregar reservas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromARGB(255, 0, 0, 0),
        child: SafeArea(
          child: SingleChildScrollView( // Permite rolagem quando necessário
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Alinhamento horizontal centralizado
              children: [
                const SizedBox(height: 40),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _showImageChangeDialog();
                    },
                    child: Stack(
                      alignment: Alignment.center, // Centraliza o CircularProgressIndicator na imagem
                      children: [
                        ClipOval(
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: _imagePath != null
                                ? Image.network(
                                    _imagePath!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    "images/FotoPerfil.jpeg",
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        if (_isLoading) const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _clienteNome ?? '',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 190, top: 32, bottom: 16),
                  child: Text(
                    "Escolha uma opção:".toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Colors.white70),
                  ),
                ),
                // Remover Flexible e adicionar Container com altura limitada
                Container(
                  constraints: BoxConstraints(maxHeight: 400), // Limita a altura
                  child: SideMenuTitle(
                    userId: userId,
                    db: db,
                    reservas: _reservas,
                  ),
                ),
                const SizedBox(height: 20), // Espaçamento adicional
              ],
            ),
          ),
        ),
      ),
    );
  }




}
