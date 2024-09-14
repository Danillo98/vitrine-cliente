import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitrine/pages/perfil_page.dart'; // Import necessário para abrir URLs.

class ItemPesquisadoPage extends StatefulWidget {
  final Map<String, dynamic> produto;
  final String telefone;

  const ItemPesquisadoPage({
    Key? key,
    required this.produto,
    required this.telefone,
  }) : super(key: key);

  @override
  _ItemPesquisadoPageState createState() => _ItemPesquisadoPageState();
}

class _ItemPesquisadoPageState extends State<ItemPesquisadoPage> {
  // Método para abrir o WhatsApp
void _abrirWhatsApp(String telefone, String mensagem) async {
  final whatsappUrl = "https://wa.me/$telefone?text=${Uri.encodeFull(mensagem)}";
  try {
    await launch(whatsappUrl);
  } catch (e) {
    throw 'Não foi possível abrir o WhatsApp.';
  }
}


  @override
  Widget build(BuildContext context) {
    final produto = widget.produto;
    final telefone = widget.telefone; // Pegue o telefone da loja do widget
    final fotoLoja = produto['foto_loja'] ?? '';
    final nomeLoja = produto['nome_loja'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      child: produto['img'] != null && produto['img'].isNotEmpty
                          ? Image.network(
                              produto['img'],
                              fit: BoxFit.cover,
                              height: 350,
                              width: double.infinity,
                            )
                          : SizedBox.shrink(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              produto['nomeitem'] ?? 'Nome não disponível',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            produto['descricao'] ?? 'Descrição não disponível',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Tamanho: ${produto['tamanho'] ?? 'Não disponível'}",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Cor: ${produto['cor'] ?? 'Não disponível'}",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Valor: ${produto['preco'] ?? 'Preço não disponível'}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
  onTap: () {
    final nomeProduto = produto['nomeitem'] ?? 'Produto não disponível';
    final mensagem = 'Olá, Gostei do(a) $nomeProduto e gostaria de reservá-lo(a)!';
    _abrirWhatsApp(widget.telefone, mensagem);
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
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(fotoLoja),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      nomeLoja,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PerfilPage(
                              nomeLoja: nomeLoja,
                              imageUrl: fotoLoja,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Ir para Vitrine",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
