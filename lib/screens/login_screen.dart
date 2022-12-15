import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smartgolfportal/services/auth_service.dart';

import '../router.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = "";
  bool _isLoading = false;

  void loginUser(WidgetRef ref) async {
    setState(() {
      _isLoading = true;
    });

    ref
        .watch(userStateProvider.notifier)
        .signIn(
            username: _usernameController.text,
            password: _passwordController.text)
        .then((val) {
      if (val) {
        Get.offNamed(AppRoutes.userScreen);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception:", "");
        _isLoading = false;
      });
    });
  }

  Widget inputBox(Widget child) => Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      constraints: const BoxConstraints(maxWidth: 300),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: child);

  @override
  Widget build(BuildContext context) {
    // _usernameController.text = "jacques.jstoeps@gmail.com";
    // _passwordController.text = "12345678";

    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(maxHeight: Get.height * 0.3),
                child: Image.asset("assets/images/smart_stats_logo.png"),
              ),
              Card(
                color: Get.theme.primaryColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        inputBox(
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                                hintText: "Username", border: InputBorder.none),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a username";
                              }
                              return null;
                            },
                          ),
                        ),
                        inputBox(
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                                hintText: "Password", border: InputBorder.none),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a password";
                              }
                              return null;
                            },
                          ),
                        ),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        Consumer(
                          builder: (context, ref, _) => ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white)),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                loginUser(ref);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: _isLoading
                                  ? const CircularProgressIndicator.adaptive()
                                  : Text(
                                      'LOGIN',
                                      style: TextStyle(
                                          color: Get.theme.primaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
