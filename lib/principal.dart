import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vitrine/componentes/side_menu.dart';
import 'package:vitrine/componentes/side_menu_title.dart';
import 'package:vitrine/pages/item_pesquisado_page.dart';

import 'package:vitrine/pages/perfil_page.dart';
import 'package:vitrine/pages/suporte_page.dart';
import 'firebase_options.dart';
import 'database.dart';
import 'dart:async';
import 'pages/favoritas_page.dart';




class Principal extends StatelessWidget {
  const Principal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tela Principal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Seu produto está aqui!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

StreamController<List<Map<String, dynamic>>?> searchResultsController =
    StreamController<List<Map<String, dynamic>>?>.broadcast();

class _MyHomePageState extends State<MyHomePage> {
  
  late Database db;
  List docs = [];
  List<bool> selectedItems = List.generate(0, (_) => false);
  TextEditingController _filtragemController = TextEditingController();
  List<Map<String, dynamic>> usuariosLoja = [];
  bool isSearching = false; 
  String? cidadeSelecionada;

  @override
  void initState() {
    super.initState();
    db = Database();
    db.initialize();
    initialize();
  }

  void initialize({String? cidade}) async {
  try {
    List<Map<String, dynamic>> result = await db.listarUsuariosLoja(cidade: cidade);
    setState(() {
      usuariosLoja = result;
    });
  } catch (e) {
    print('Erro ao inicializar dados: $e');
  }
}


void _filtrandoTudo(String query) async {
  if (query.isNotEmpty) {
    List<dynamic> resultados = await db.filtrarInformacoes(query, cidade: cidadeSelecionada);
    print('Resultados da filtragem: $resultados');
    setState(() {
      docs = resultados;
      isSearching = true;
    });
  } else {
    // Se a consulta estiver vazia, reverta para todos os itens
    setState(() {
      docs = List.from(usuariosLoja); // Cria uma cópia da lista original
      isSearching = false;
      print('Consulta vazia, revertendo para todos os itens: $docs');
    });
  }
}


  void _atualizarListaDeLojas() {
    initialize(); // Chame initialize sem parâmetros para restaurar todas as lojas
  }




void _filtrarPorCidade(String cidade) {
  setState(() {
    cidadeSelecionada = cidade;
  });
  initialize(cidade: cidade);
}


  void _navegarParaFavoritas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavoritasPage()),
    );
  }

  


  Widget _buildImageWidget(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(imageUrl),
      );
    } else {
      // Caso a URL da imagem seja inválida, retornamos um widget de espaço reservado
      return Placeholder(
        fallbackHeight: 80, // Altura do espaço reservado
        fallbackWidth: 80, // Largura do espaço reservado
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        leading: IconButton(
          icon: Image.asset("images/btnopcao.png"),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SideMenu(),
              ),
            );
          },
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Escolha uma Cidade:',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _filtrarPorCidade('Itaperuna');
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Itaperuna',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _filtrarPorCidade('Campos dos Goytacazes');
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Campos dos Goytacazes',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _filtrarPorCidade('Macaé');
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Macaé',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Fechar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Image.asset("images/mapa.png"),
          ),
        ],
      ),
      // Defina resizeToAvoidBottomInset como false
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _filtragemController,
              onChanged: (query) {
                _filtrandoTudo(query);
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: isSearching ? _buildItemList() : _buildStoreList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        onPressed: () {
          _navegarParaFavoritas();
        },
        tooltip: 'Favoritas',
        child: Image.asset(
          "images/btndiamante.png",
        ),
      ),
    );
  }


//Listagem das Lojas
  Widget _buildStoreList() {
    return ListView.builder(
      itemCount: usuariosLoja.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilPage(
                      nomeLoja: usuariosLoja[index]['nomeLoja'] ?? '',
                      imageUrl: usuariosLoja[index]['img'] ?? '',
                    ),
                  ),
                );
              },
              leading: Container(
                width: 80, // Defina o tamanho desejado aqui
                height: 80, // Defina o tamanho desejado aqui
                child: _buildImageWidget(usuariosLoja[index]['img']),
              ),
              title: Text(usuariosLoja[index]['nomeLoja'] ?? ''),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 25,
            ),
          ],
        );
      },
    );
  }
  

// Listagem dos produtos pesquisados
  Widget _buildItemList() {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ListTile(

            onTap: () async {
            // Primeiro, extraia os dados do documento atual.
            final produtoDados = docs[index];
            final userId = produtoDados['userId'];

            // Busca as informações da loja correspondente no Firestore
            final lojaSnapshot = await FirebaseFirestore.instance
                .collection('usersadm')
                .doc(userId)
                .get();

            if (lojaSnapshot.exists) {
              final lojaDados = lojaSnapshot.data()!;

              // Combine os dados de 'produtoDados' e 'lojaDados' para garantir que todos os dados necessários estejam presentes.
              final produtoCompleto = {
                'nomeitem': produtoDados['nomeitem'] ?? '',
                'foto_loja': lojaDados['profileImage'] ?? '',
                'nome_loja': lojaDados['nome'] ?? '',
                'descricao': produtoDados['descricao'] ?? '',
                'tamanho': produtoDados['tamanho'] ?? '',
                'cor': produtoDados['cor'] ?? '',
                'preco': produtoDados['preco'] ?? '',
                'img': produtoDados['img'] ?? '',
                // Adicione quaisquer outros campos que possam ser necessários.
              };

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemPesquisadoPage(
                    produto: produtoCompleto,
                    telefone: lojaDados['telefone'] ?? 'SeuNúmeroDeTelefone', // Substitua com o telefone correto
                  ),
                ),
              );
            } else {
              // Trate o caso em que a loja não foi encontrada
              print("Loja não encontrada para o userId: $userId");
            }
          },


              leading: Container(
                width: 80, // Defina o tamanho desejado aqui
                height: 80, // Defina o tamanho desejado aqui
                child: _buildImageWidget(docs[index]['img']),
              ),
              title: Text(docs[index]['nomeitem'] ?? ''),
              subtitle: Text(docs[index]['descricao'] ?? ''),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 25,
            ),
          ],
        );
      },
    );
  }
  
  
}
