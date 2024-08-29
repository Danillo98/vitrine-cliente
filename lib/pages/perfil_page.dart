import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitrine/pages/favoritas_page.dart';
import 'package:vitrine/reserva.dart';
import 'package:vitrine/pages/reservas_page.dart';
import 'package:vitrine/database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show UrlLauncher, Intent;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;


class PerfilPage extends StatefulWidget {
  final String nomeLoja;
  final String imageUrl;

  const PerfilPage({Key? key, required this.nomeLoja, required this.imageUrl})
      : super(key: key);

  @override
  State<PerfilPage> createState() => _PerfilPageInfoState();
}

class _PerfilPageInfoState extends State<PerfilPage> {
  late String telefone = '';
  late String endereco = '';
  late String cidade = ''; 

  List<Map<String, dynamic>> produtos = [];
  List<Map<String, dynamic>> reservas = [];

  @override
  void initState() {
    super.initState();
    _fetchLojaData();
  }

  Future<void> _fetchLojaData() async {
    try {
      print('Nome da loja: ${widget.nomeLoja}');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usersadm')
          .where('nome', isEqualTo: widget.nomeLoja)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String idDocumento = querySnapshot.docs.first.id;

        print('ID do documento: $idDocumento');

        DocumentSnapshot lojaSnapshot = await FirebaseFirestore.instance
            .collection('usersadm')
            .doc(idDocumento)
            .get();

        Map<String, dynamic> lojaData =
            lojaSnapshot.data() as Map<String, dynamic>;

      
       // Alterado o caminho para acessar a nova coleção "Items"
        QuerySnapshot produtosQuerySnapshot = await FirebaseFirestore.instance
          .collection('Items')
          .where('userId', isEqualTo: idDocumento)
          .get();


        List<Map<String, dynamic>> produtos = produtosQuerySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        print('Produtos da loja: $produtos');

        setState(() {
          telefone = lojaData['telefone'] ?? '';
          endereco = lojaData['endereco'] ?? '';
          cidade = lojaData['cidade'] ?? '';
          this.produtos = produtos;
        });
      } else {
        print('Nenhum documento encontrado para ${widget.nomeLoja}');
      }
    } catch (e) {
      print('Erro ao buscar dados da loja: $e');
    }
  }



void _favoritarLoja() async {
  try {
    // Verificar se há um usuário autenticado
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Referência para a coleção 'userscliente'
      CollectionReference usersClienteRef = FirebaseFirestore.instance.collection('userscliente');

      // Referência para o documento do usuário logado
      DocumentReference userDocRef = usersClienteRef.doc(user.uid);

      // Referência para a coleção 'Favoritas' dentro do documento do usuário
      CollectionReference favoritasRef = userDocRef.collection('Favoritas');

      // Verificar se a loja já está favoritada
      QuerySnapshot querySnapshot = await favoritasRef
          .where('nomeLoja', isEqualTo: widget.nomeLoja)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Loja já está favoritada, exibir mensagem apropriada
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Esta Vitrine já é favorita!'),
            duration: Duration(seconds: 1), // Duração reduzida para 2 segundos
          ),
        );
      } else {
        // Adicionar a Favoritas à coleção 'Favoritas' do usuário
        await favoritasRef.add({
          'nomeLoja': widget.nomeLoja,
          'imageUrl': widget.imageUrl,
        });

        // Feedback para o usuário de que a loja foi favoritada com sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Favoritada com sucesso!'),
            duration: Duration(seconds: 1), // Duração reduzida para 2 segundos
          ),
        );
      }
    } else {
      // Caso não haja usuário autenticado, exibir uma mensagem de erro
      throw 'Nenhum usuário autenticado.';
    }
  } catch (e) {
    print('Erro ao favoritar loja: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao favoritar loja'),
        duration: Duration(seconds: 2), // Duração reduzida para 2 segundos
      ),
    );
  }
}




void _abrirWhatsApp(String telefone, String mensagem) async {
  final whatsappUrl = "https://wa.me/$telefone?text=${Uri.encodeFull(mensagem)}";
  try {
    await launch(whatsappUrl);
  } catch (e) {
    throw 'Não foi possível abrir o WhatsApp.';
  }
}


void _abrirRotaNoGoogleMaps(String endereco, String cidade) async {
    final enderecoCompleto = '$endereco, $cidade'; // Concatenando a cidade ao endereço
    final url = 'https://www.google.com/maps?q=${Uri.encodeFull(enderecoCompleto)}';
    try {
      await UrlLauncher.launch(url);
    } on PlatformException catch (e) {
      // Caso ocorra algum erro, tentar abrir o Google Maps diretamente com uma Intent
      final googleMapsIntentUrl = 'geo:0,0?q=${Uri.encodeFull(enderecoCompleto)}';
      try {
        await UrlLauncher.launch(googleMapsIntentUrl);
      } catch (e) {
        throw 'Não foi possível abrir o Google Maps.';
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Color.fromARGB(255, 0, 0, 0),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.48,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(widget.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              widget.nomeLoja,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            buildInfoRowWithDivider(
                              "Telefone:",
                              telefone,               
                                icon:GestureDetector(
                              onTap: () async {
                                final whatsappUrl = "https://wa.me/$telefone";
                                try {
                                  await launch(whatsappUrl);
                                } catch (e) {
                                  throw 'Não foi possível abrir o WhatsApp.';
                                }
                              },
                                  child: Image.asset(
                                    "images/iconewhatsapp.png",
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                              
                            ),
                                
                            buildInfoRowWithDivider(
                              "Endereço:",
                              '$endereco, $cidade', // Concatenando a cidade ao endereço
                              icon: GestureDetector(
                                onTap: () {
                                  _abrirRotaNoGoogleMaps(endereco, cidade); // Passando a cidade como parâmetro
                                },
                                child: Image.asset(
                                  "images/iconegps.png",
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 6, right: 6),
                    child: SingleChildScrollView(
                      child: Column(
                        children: produtos.map((produto) {
                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0.0, 2.0),
                                  blurRadius: 6.0,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    child: produto['img'] != null
                                        ? Image.network(
                                            produto['img'],
                                            fit: BoxFit.cover,
                                          )
                                        : SizedBox.shrink(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 1),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  produto['nomeitem'] != null &&
                                                          produto['nomeitem']
                                                              .isNotEmpty
                                                      ? produto['nomeitem']
                                                      : 'Nome não disponível',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 33,
                                                    fontFamily: 'Work Sans',
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        produto['descricao'] != null &&
                                                produto['descricao'].isNotEmpty
                                            ? "Descrição: ${produto['descricao']}"
                                            : 'Descrição não disponível',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        produto['tamanho'] != null &&
                                                produto['tamanho'].isNotEmpty
                                            ? "Tamanho: ${produto['tamanho']}"
                                            : 'Tamanho não disponível',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        produto['cor'] != null &&
                                                produto['cor'].isNotEmpty
                                            ? "Cor: ${produto['cor']}"
                                            : 'Cor não disponível',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                     Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          produto['preco'] != null && produto['preco'].isNotEmpty
                                              ? "Valor: ${produto['preco']}"
                                              : 'Preço não disponível',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 25,
                                            fontFamily: 'Work Sans',
                                            fontStyle: FontStyle.italic,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                             final nomeProduto = produto['nomeitem'] ?? 'Produto não disponível';
                                              final mensagem = 'Olá, Gostei do(a) $nomeProduto e gostaria de reservá-lo(a)!';

                                              final url = 'https://wa.me/$telefone?text=${Uri.encodeFull(mensagem)}';
                                              _abrirWhatsApp(telefone, mensagem);
                                            if (await canLaunch(url)) {
                                              await launch(url);
                                            } else {
                                              throw 'Não foi possível abrir $url';
                                            }
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Icon(
                                                Icons.favorite,
                                                color: Colors.black,
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  SizedBox(height: 30), // Ajuste o espaçamento vertical aqui
                                                  Text(
                                                    'Reservar',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),


                                      ],
                                    ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
     floatingActionButton: Align(
        alignment: Alignment(1.0, -0.8),
        child: FloatingActionButton(
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          onPressed: _favoritarLoja,
          child: Image.asset(
            "images/btndiamante.png",
          ),
        ),
      ),
    );
  }


  Widget buildInfoRowWithIcon(String label, String value, {Widget? icon}) {
    return Row(
      children: [
        buildInfoRow(label, value),
        Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: icon ?? Container(),
        ),
      ],
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget buildInfoRowWithDivider(String label, String value, {Widget? icon}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: icon ?? Container(),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
