//auth.dart

import 'package:firebase_news_flutter/application/core/services/auth_services.dart';
import 'package:firebase_news_flutter/domain/usecases/auth_usecases.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widget/user_image_picker2.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});
  final _form = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();

  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/messages.png'),
              ),
              Consumer<AuthService>(
                builder: (context, authService, child) {
                  return Card(
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _form,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!authService.getIsLogin())
                                UserImagePicker(
                                  onPickImage: (pickedImage) {
                                    Provider.of<AuthService>(context, listen: false).changeAuthImage(pickedImage);
                                  },
                                ),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Email Address'),
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains('@')) {
                                    return 'Please enter a valid email address.';
                                  }

                                  return null;
                                },
                              ),
                              if (!authService.getIsLogin())
                                TextFormField(
                                  decoration:
                                  const InputDecoration(labelText: 'Username'),
                                  controller: _usernameController,
                                  enableSuggestions: false,
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.trim().length < 4) {
                                      return 'Please enter at least 4 characters.';
                                    }
                                    return null;
                                  },
                                ),
                              TextFormField(
                                decoration:
                                const InputDecoration(labelText: 'Password'),
                                controller: _passwordController,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.trim().length < 6) {
                                    return 'Password must be at least 6 characters long.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              if (authService.getIsAuthenticating())
                                const CircularProgressIndicator(),
                              if (!authService.getIsAuthenticating())
                                ElevatedButton(
                                  onPressed: () {
                                    print("IS_LOGIN_SUBMIT: ${Provider.of<AuthService>(context, listen: false).getIsLogin()}");
                                    AuthUseCases().submit(
                                        form: _form,
                                        context: context,
                                        enteredEmail: _emailController.text,
                                        enteredPassword: _passwordController.text,
                                        enteredUsername: _usernameController.text
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  child: Text(authService.getIsLogin() ? 'Login' : 'Signup'),
                                ),
                              if (!authService.getIsAuthenticating())
                                TextButton(
                                  onPressed: () {

                                    Provider.of<AuthService>(context, listen: false).changeIsLogin();
                                    print("IS_LOGIN: ${Provider.of<AuthService>(context, listen: false).getIsLogin()}");
                                  },
                                  child: Text(authService.getIsLogin()
                                      ? 'Create an account'
                                      : 'I already have an account'),
                                ),
                              ElevatedButton(
                                  onPressed: () async {
                                    await AuthUseCases().signInWithGoogle();
                                  },
                                  child: Text(
                                    'Sign in with google'
                                  )
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}