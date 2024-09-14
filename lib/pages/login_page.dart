import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vitrine/pages/senha_page.dart';
import 'package:vitrine/pages/register_page.dart';
import 'package:vitrine/utils/fire_auth.dart';
import 'package:vitrine/utils/validator.dart';

import 'package:vitrine/principal.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

chamarTela(BuildContext context, StatelessWidget widget) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
}


class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;
  bool _isFirebaseInitialized = false;

  @override
  void initState() {
    super.initState();

    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    if (!_isFirebaseInitialized) {
      await Firebase.initializeApp();
      setState(() {
        _isFirebaseInitialized = true;
      });
    }
  }

    Future<void> _checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;

    if (user?.emailVerified == true) {
      _navigateToHome();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            title: const Text('Verificação de E-mail Necessária'),
            content: const Text('Você precisa verificar seu e-mail antes de prosseguir.'),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  await user?.sendEmailVerification();
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        title: const Text('E-mail de Verificação Enviado'),
                        content: const Text('Um e-mail de verificação foi enviado!'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  'Verificar',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }


Future<void> _checkIsAdm(String email) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;
      final isAdm = userDoc.data()?['isAdm'] as bool?;
      
      print('Email: $email, isAdm: $isAdm'); // Debugging print

      if (isAdm == false) {
        // Se não for Admin, verifica o e-mail
        _checkEmailVerification();
      } else {
        // Se for Admin, exibe diálogo e bloqueia login
        _showAccessDeniedDialog();
      }
    } else {
      // Usuário não encontrado, exibe diálogo de erro
      print('Usuário não encontrado');
      _showAccessDeniedDialog();
    }
  } catch (e) {
    print('Erro ao verificar isAdm: $e');
    _showAccessDeniedDialog();
  }
}

void _showAccessDeniedDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Acesso Negado'),
        content: const Text(
          'Esse email está registrado como Administrador. Acesse o aplicativo VITRINE ADM!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    if (!_isFirebaseInitialized) {
      return const CircularProgressIndicator();
    }

    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "images/background5.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Container(
              color: const Color.fromARGB(137, 255, 255, 255),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset("images/LogoVitrine2.png"),
                      ),
                      const SizedBox(height: 20.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _emailTextController,
                              focusNode: _focusEmail,
                              validator: (value) => Validator.validateEmail(
                                email: value,
                              ),
                              decoration: InputDecoration(
                                hintText: "Email",
                                prefixIcon: const Icon(Icons.email),
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
                            const SizedBox(height: 8.0),
                            TextFormField(
                              controller: _passwordTextController,
                              focusNode: _focusPassword,
                              obscureText: true,
                              validator: (value) => Validator.validatePassword(
                                password: value,
                              ),
                              decoration: InputDecoration(
                                hintText: "Senha",
                                prefixIcon: const Icon(Icons.lock),
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
                            const SizedBox(height: 30.0),
                            _isProcessing
                                ? const CircularProgressIndicator()
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            _focusEmail.unfocus();
                                            _focusPassword.unfocus();

                                            if (_formKey.currentState!.validate()) {
                                              setState(() {
                                                _isProcessing = true;
                                              });

                                              User? user = await FireAuth.signInUsingEmailPassword(
                                                email: _emailTextController.text,
                                                password: _passwordTextController.text,
                                              );

                                              setState(() {
                                                _isProcessing = false;
                                              });

                                              if (user != null) {
                                                await _checkIsAdm(_emailTextController.text);
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                                      title: const Text('Erro de Autenticação'),
                                                      content: const Text('E-mail ou senha incorretos.'),
                                                      actions: [
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          child: const Text(
                                                            'OK',
                                                            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            }
                                          },
                                          child: const Text(
                                            'Entrar',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 24.0),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RegisterPage(
                                                  userId: FirebaseAuth.instance
                                                          .currentUser?.uid ??
                                                      '',
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Registrar',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 50.0),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SenhaPage()),
                                );
                              },
                              child: const Text('Esqueceu sua senha?'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
    Future<void> _navigateToHome() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MyApp(),
      ),
    );
  }
}

