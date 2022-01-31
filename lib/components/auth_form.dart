import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/models/auth.dart';

enum AuthMode { signup, login }

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  AuthMode authMode = AuthMode.login;
  Map<String, String> authData = {
    'email': '',
    'password': '',
  };

  AnimationController? _controller;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  bool _isLogin() => authMode == AuthMode.login;
  // bool _isSignup() => authMode == AuthMode.signup;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );

    // _heightAnimation?.addListener(() {
    //   setState(() {});
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        authMode = AuthMode.signup;
        _controller?.forward();
      } else {
        authMode = AuthMode.login;
        _controller?.reverse();
      }
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ocorreu um erro'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          )
        ],
      ),
    );
  }

  Future<void> submit() async {
    final isValid = formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    setState(() => isLoading = true);

    formKey.currentState?.save();
    Auth auth = Provider.of<Auth>(context, listen: false);

    try {
      if (_isLogin()) {
        await auth.login(
          authData['email']!,
          authData['password']!,
        );
      } else {
        await auth.signUp(
          authData['email']!,
          authData['password']!,
        );
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('Ocorreu um erro desconhecido!');
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
        padding: const EdgeInsets.all(16),
        height: _isLogin() ? 310 : 400,
        // height: _heightAnimation?.value.height ?? (_isLogin() ? 310 : 400),
        width: deviceSize.width * 0.75,
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => authData['email'] = email ?? '',
                validator: (emailValidator) {
                  final email = emailValidator ?? '';
                  if (email.trim().isEmpty || !email.contains('@')) {
                    return 'Informe um e-mail válido';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Senha'),
                controller: passwordController,
                obscureText: true,
                onSaved: (password) => authData['password'] = password ?? '',
                validator: (passwordValidator) {
                  final password = passwordValidator ?? '';
                  if (password.isEmpty || password.length < 5) {
                    return 'Informe uma senha válida';
                  } else {
                    return null;
                  }
                },
              ),
              AnimatedContainer(
                constraints: BoxConstraints(
                  minHeight: _isLogin() ? 0 : 60,
                  maxHeight: _isLogin() ? 0 : 120,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                child: FadeTransition(
                  opacity: _opacityAnimation!,
                  child: SlideTransition(
                    position: _slideAnimation!,
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Confirmar Senha'),
                      keyboardType: TextInputType.emailAddress,
                      obscureText: true,
                      validator: _isLogin()
                          ? null
                          : (passwordValidator) {
                              final password = passwordValidator ?? '';
                              if (password != passwordController.text) {
                                return 'Senhas informadas não conferem';
                              } else {
                                return null;
                              }
                            },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: submit,
                  child: Text(_isLogin() ? 'ENTRAR' : 'REGISTRAR'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: _switchAuthMode,
                child: Text(
                  _isLogin() ? 'DESEJA REGISTRAR?' : 'JÁ POSSUI CONTA?',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
