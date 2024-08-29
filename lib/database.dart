import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitrine/Cliente.dart';
import 'package:vitrine/reserva.dart';

class Database {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void initialize() {
    _firestore = FirebaseFirestore.instance;
  }
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }


Future<void> remover_favorito(String docId) async {
    try {
      String? userId = getCurrentUserId();
      if (userId != null) {
        await _firestore
            .collection('userscliente')
            .doc(userId)
            .collection('Favoritas')
            .doc(docId)
            .delete();
      }
    } catch (e) {
      print('Erro ao remover favorito: $e');
      throw e;
    }
  }



  Future<void> incluireservas(Reserva c) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      final reservaData = {
        "nomeloja": c.nomeloja,
        "endereco": c.endereco,
        "telefone": c.telefone,
        "nomeitem": c.nomeitem,
        "cor": c.cor,
        "tamanho": c.tamanho,
        "descricao": c.descricao,
        "preco": c.preco,
        "img": c.img,
        "userId": user?.uid, // Adiciona o ID do usuário que está fazendo a reserva
      };

      await _firestore
          .collection('userscliente')
          .doc(user?.uid)
          .collection('reservas')
          .add(reservaData);

      print('Reserva adicionada com sucesso');
    } catch (e) {
      print('Erro ao adicionar reserva: $e');
    }
  }

Future<List<Map<String, dynamic>>> listar() async {
  try {
    QuerySnapshot querySnapshot = await _firestore.collection('Items').get();

    List<Map<String, dynamic>> docs = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {
        "nomeitem": data['nomeitem'],
        "cor": data['cor'],
        "tamanho": data['tamanho'],
        "descricao": data['descricao'],
        "preco": data['preco'],
        "img": data['img'],
        "userId": data['userId'], // Adiciona o campo userId se precisar referenciar o usuário
      };
    }).toList();

    print('Itens obtidos com sucesso: $docs');
    return docs;
  } catch (e) {
    print('Erro ao listar itens: $e');
    return [];
  }
}



Future<List<Map<String, dynamic>>> filtrarInformacoes(String query, {String? cidade}) async {
  try {
    Query queryRef = _firestore.collection('Items');

    // Filtra os itens por cidade se uma cidade estiver selecionada
    if (cidade != null && cidade.isNotEmpty) {
      final cidadeSnapshot = await _firestore.collection('usersadm').where('cidade', isEqualTo: cidade).get();
      List<String> userIds = cidadeSnapshot.docs.map((doc) => doc.id).toList();
      queryRef = queryRef.where('userId', whereIn: userIds);
    }

    QuerySnapshot querySnapshot = await queryRef.get();

    List<Map<String, dynamic>> itens = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {
        "nomeitem": data['nomeitem'],
        "cor": data['cor'],
        "tamanho": data['tamanho'],
        "descricao": data['descricao'],
        "preco": data['preco'],
        "img": data['img'],
        "userId": data['userId'],
      };
    }).toList();

    List<Map<String, dynamic>> resultados = itens.where((item) {
      return item['nomeitem'].toLowerCase().contains(query.toLowerCase()) ||
             item['cor'].toLowerCase().contains(query.toLowerCase()) ||
             item['tamanho'].toLowerCase().contains(query.toLowerCase()) ||
             item['descricao'].toLowerCase().contains(query.toLowerCase()) ||
             item['preco'].toString().toLowerCase().contains(query.toLowerCase());
    }).toList();

    print('Resultados da filtragem: $resultados');
    return resultados;
  } catch (e) {
    print('Erro ao filtrar informações: $e');
    return [];
  }
}






Future<List<Map<String, dynamic>>> listar_favoritos() async {
  User? user = FirebaseAuth.instance.currentUser;

  try {
    QuerySnapshot querySnapshot = await _firestore
        .collection('userscliente')
        .doc(user?.uid)
        .collection('Favoritas')
        .orderBy("nomeLoja")
        .get();

    List<Map<String, dynamic>> docs = querySnapshot.docs.map((doc) {
      return {
        "docId": doc.id, 
        "nomeLoja": doc['nomeLoja'],
        "imageUrl": doc['imageUrl'],
      };
    }).toList();

    print('Favoritas obtidos com sucesso: $docs');
    return docs;
  } catch (e) {
    print('Erro ao listar favoritas: $e');
    return [];
  }
}







Future<List<Map<String, dynamic>>> listarUsuariosLoja({String? cidade}) async {
  try {
    Query query = _firestore.collection('usersadm');
    if (cidade != null && cidade.isNotEmpty) {
      query = query.where('cidade', isEqualTo: cidade);
    }
    QuerySnapshot querySnapshot = await query.get();

    List<Map<String, dynamic>> usuarios = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {
        "nomeLoja": data['nome'],
        "img": data['profileImage'],
        "cidade": data['cidade'],
        // Adicione outros campos conforme necessário
      };
    }).toList();

    return usuarios;
  } catch (e) {
    print('Erro ao listar usuários: $e');
    return [];
  }
}


  Future<void> editarCliente(String id, Cliente j) async {
    try {
      DocumentReference clienteRef = _firestore
          .collection('userscliente')
          .doc(id); // Use o ID do cliente, não o ID do usuário

      DocumentSnapshot clienteSnapshot = await clienteRef.get();
      if (clienteSnapshot.exists) {
        final Cliente = <String, dynamic>{
          "nome": j.nome,
          "telefone": j.telefone,
          "userCliente": j.userscl,
        };

        await clienteRef.update(Cliente);
        print('Cliente $id atualizado com sucesso');
      } else {
        print('Cliente $id não atualizado');
      }
    } catch (e) {
      print('Erro ao atualizar o Cliente: $e');
    }
  }


Future<List<Map<String, dynamic>>> listarUsuariosLojaPorEndereco(String endereco) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('usersadm')
        .get();

    List<Map<String, dynamic>> lojas = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .where((loja) => loja['endereco'].toLowerCase().contains(endereco.toLowerCase()))
        .toList();

    return lojas;
  } catch (e) {
    print('Erro ao buscar lojas por endereço: $e');
    return [];
  }
}

  
  //método para buscar as informações da loja com base no ID do usuário
  Future<Map<String, dynamic>?> getLojaInfo(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('usersadm').doc(userId).get();
      return doc.data() as Map<String, dynamic>?; // Retorna as informações da loja
    } catch (e) {
      print('Erro ao buscar informações da loja: $e');
      return null;
    }
  }



 Future<List<Map<String, dynamic>>> getReservas() async { // Corrigido para retornar uma lista de mapas
  try {
    User? user = FirebaseAuth.instance.currentUser;
    QuerySnapshot querySnapshot = await _firestore
        .collection('userscliente')
        .doc(user?.uid)
        .collection('Reservas')
        .get();

    List<Map<String, dynamic>> reservas = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data;
    }).toList();

    print('Reservas obtidas com sucesso: $reservas');

    return reservas;
  } catch (e) {
    print('Erro ao obter reservas: $e');
    return [];
  }
}

  //Excluir itens do adm loja
  Future<void> excluir(String id) async {
  try {
    DocumentReference productRef = _firestore.collection('Items').doc(id);

    await productRef.delete(); // Exclui o documento do Firestore

    print('Item $id excluído com sucesso');
  } catch (e) {
    print('Erro ao excluir o documento: $e');
  }
}

  Future<Map<String, dynamic>?> getClienteInfo(String userId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('userscliente')
          .doc(userId)
          .get();
      return doc.data() as Map<String, dynamic>?; // Retorna as informações do cliente
    } catch (e) {
      print('Erro ao buscar informações do cliente: $e');
      return null;
    }
  }
  
  
}
