import 'package:firebase_auth/firebase_auth.dart';

class Validator {
  







  static String? validateNome({required String? Nome}) {
    if (Nome == null) {
      return null;
    }

    if (Nome.isEmpty) {
      return 'O nome da loja não pode estar vazio!';
    }

    return null;
  }

  static String? validateCnpj({required String? cnpj}) {
    if (cnpj == null) {
      return null;
    }

    if (cnpj.isEmpty) {
      return 'O cnpj não pode estar vazio!';
    } else if (cnpj.length < 14 || cnpj.length > 14) {
      return 'O cnpj precisa ter 14 números!';
    }

    return null;
  }

  static String? validateEndereco({required String? endereco}) {
    if (endereco == null) {
      return null;
    }

    if (endereco.isEmpty) {
      return 'O endereco não pode estar vazio!';
    }

    return null;
  }

  static String? validateNomepropietario({required String? nomepropietario}) {
    if (nomepropietario == null) {
      return null;
    }

    if (nomepropietario.isEmpty) {
      return 'O nome do propietario não pode estar vazio!';
    }

    return null;
  }

  static String? validateTelefone({required String? telefone}) {
    if (telefone == null) {
      return null;
    }

    if (telefone.isEmpty) {
      return 'O telefone não pode estar vazio!';
    } else if (telefone.length < 11 || telefone.length > 11) {
      return 'O telefone precisa ter 11 números. Verifique o DDD!';
    }

    return null;
  }

  static String? validateEmail({required String? email}) {
    if (email == null) {
      return null;
    }
    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (email.isEmpty) {
      return 'O e-mail não pode estar vazio!';
    } else if (!emailRegExp.hasMatch(email)) {
      return 'Digite um e-mail correto!';
    }
    
  }

  static String? validatePassword({required String? password}) {
    if (password == null) {
      return null;
    }

    if (password.isEmpty) {
      return 'A senha não pode estar vazia!';
    } else if (password.length < 6) {
      return 'Digite uma senha com pelo menos 6 dígitos!';
    }

    return null;
  }
}
