import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitrine/pages/verificacao_email_page.dart';
import 'package:vitrine/utils/fire_auth.dart';
import 'package:vitrine/utils/validator.dart';

class RegisterPage extends StatefulWidget {
  final String _userId;
  final String? _clienteNome;

  RegisterPage({Key? key, required String userId, String? clienteNome})
      : _userId = userId,
        _clienteNome = clienteNome,
        super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState(_userId, _clienteNome);
}

class _RegisterPageState extends State<RegisterPage> {
  final String _userId;
  final String? _clienteNome;
  _RegisterPageState(this._userId, this._clienteNome);

  final _registerFormKey = GlobalKey<FormState>();

  final _nomeclienteTextController = TextEditingController();
  final _telefoneTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusNome = FocusNode();
  final _focusTelefone = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;

  Future<void> _createClienteDocument(
    String userId, String nome, String telefone) async {
  CollectionReference userscliente =
      FirebaseFirestore.instance.collection('userscliente');

  try {
    // Adiciona o documento na coleção 'userscliente' com email incluído
    await userscliente.doc(userId).set({
      'nome': nome,
      'telefone': telefone,
      'email': _emailTextController.text, // Inclui o email aqui
    });
    
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.doc(userId).set({
      'email': _emailTextController.text,
      'isAdm': false,
    });

  } catch (e) {
    print('Erro ao criar documento do cliente: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNome.unfocus();
        _focusTelefone.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          title: Text(
            'Cadastre-se aqui ...',
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
          ),
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _registerFormKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _nomeclienteTextController,
                        focusNode: _focusNome,
                        validator: (value) => Validator.validateNome(
                          Nome: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Nome",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _telefoneTextController,
                        focusNode: _focusTelefone,
                        validator: (value) => Validator.validateTelefone(
                          telefone: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Telefone",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                        TextFormField(
                        controller: _emailTextController,
                        focusNode: _focusEmail,
                        validator: (value) => Validator.validateEmail(
                          email: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Email",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordTextController,
                        focusNode: _focusPassword,
                        obscureText: true,
                        validator: (value) => Validator.validatePassword(
                          password: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Senha",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      _isProcessing
                          ? const CircularProgressIndicator()
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_registerFormKey.currentState!.validate()) {
                                        setState(() {
                                          _isProcessing = true;
                                        });

                                        User? user = await FireAuth.registerUsingEmailPassword(
                                          name: _nomeclienteTextController.text,
                                          email: _emailTextController.text,
                                          password: _passwordTextController.text,
                                        );

                                        setState(() {
                                          _isProcessing = false;
                                        });

                                        if (user == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('A conta já existe para esse e-mail.'),
                                            ),
                                          );
                                        } else {
                                          // Cria o documento do cliente e adiciona à coleção 'users'
                                          await _createClienteDocument(
                                            user.uid,
                                            _nomeclienteTextController.text,
                                            _telefoneTextController.text,
                                          );

                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          await prefs.setString(
                                            'Cliente_nome_$_userId',
                                            _nomeclienteTextController.text,
                                          );

                                          Navigator.of(context).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (context) => VerificacaoEmailPage(user: user),
                                            ),
                                            ModalRoute.withName('/'),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Registrar-se',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                    ),
                                  ),
                                ),
                              ],
                            )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
