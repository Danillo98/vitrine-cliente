import 'package:firebase_auth/firebase_auth.dart';

class Reserva {
  User? userReserva= FirebaseAuth.instance.currentUser;
  String nomeloja;
  String endereco;
  String telefone;
  String nomeitem;
  String cor;
  String tamanho;
  String descricao;
  String preco;
  String img;
  
  Reserva(
    this.nomeloja,
    this.endereco,
    this.telefone,
    this.nomeitem,
    this.cor,
    this.tamanho,
    this.descricao,
    this.preco,
    this.img,
    this.userReserva,
  );
}
