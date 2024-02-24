import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitrine/widgets/verificacao_email.dart';
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

  Future<bool> _checkEmailExists(String email) async {
  try {
    // Use o método `fetchSignInMethodsForEmail` do FirebaseAuth para verificar se o e-mail já está cadastrado para autenticação
    List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    
    // Se signInMethods não estiver vazio, significa que o e-mail já está registrado
    return signInMethods.isNotEmpty;
  } catch (e) {
    // Em caso de erro, trate conforme necessário
    print('Erro ao verificar e-mail: $e');
    return false;
  }
}

  Future<void> _createClienteDocument(
      String userId, String nome, String telefone) async {
    CollectionReference userscliente =
        FirebaseFirestore.instance.collection('userscliente');

    try {
      await userscliente.doc(userId).set({
        'nome': nome,
        'telefone': telefone,
      });
    } catch (e) {
      print('Erro ao criar documento da Cliente: $e');
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
                          enabledBorder: UnderlineInputBorder(
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
                      //---------------------------------------------------BOTÂO REGISTRAR-SE-------------------------------------------------
                      const SizedBox(height: 32.0),
                      _isProcessing
                          ? const CircularProgressIndicator()
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (_registerFormKey.currentState!
                                          .validate()) {
                                        setState(() {
                                          _isProcessing = true;
                                        });
                                        // Verifica se o e-mail já está registrado
                                        bool emailExists = await _checkEmailExists(
                                            _emailTextController.text);
                                         // Adiciona um pequeno atraso após o término do processamento
                                        await Future.delayed(Duration(milliseconds: 3000));
                                        
                                        if (emailExists == true) {
                                          // E-mail já registrado, exibe mensagem e não permite o registro
                                          setState(() {
                                            _isProcessing = false;
                                          });
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('E-mail já registrado'),
                                                content: Text(
                                                    'O e-mail fornecido já está em uso. Por favor, use outro e-mail.'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          // Registro de usuário
                                          User? user = await FireAuth
                                              .registerUsingEmailPassword(
                                            name: _nomeclienteTextController.text,
                                            email: _emailTextController.text,
                                            password:
                                                _passwordTextController.text,
                                          );

                                          // Criação do documento da Cliente associado ao usuário
                                          if (user != null) {
                                            await _createClienteDocument(
                                                user.uid,
                                                _nomeclienteTextController.text,
                                                _telefoneTextController.text,
                                            );
                                          }

                                          // Salvar o nome da Cliente nas SharedPreferences (se necessário)
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          await prefs.setString(
                                              'Cliente_nome_$_userId',
                                              _nomeclienteTextController.text,
                                          );

                                          setState(() {
                                            _isProcessing = false;
                                          });

                                          if (user != null) {
                                            // ignore: use_build_context_synchronously
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfilePage(user: user),
                                              ),
                                              ModalRoute.withName('/'),
                                            );
                                          }
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
