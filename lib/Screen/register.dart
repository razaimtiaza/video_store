import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_downloader/Screen/login.dart';

class registerPage extends StatefulWidget {
  const registerPage({super.key});

  @override
  State<registerPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<registerPage> {
  bool _isPasswordVisible = false; // Added state for password visibility

  bool isPasswordVisible = false; // Added state for password visibility
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  String? _validateEmail(String email) {
    if (!email.endsWith('@gmail.com')) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (!password.contains(RegExp(r'[a-zA-Z]')) ||
        !password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain both letters and numbers';
    }
    return null; // Return null for a valid password
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RegisterPage'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'name',
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                  obscureText: !_isPasswordVisible,
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: _togglePasswordVisibility,
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  )),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      String? emailValidation =
                          _validateEmail(emailController.text);
                      String? passwordValidation =
                          _validatePassword(passwordController.text);

                      if (emailValidation != null ||
                          passwordValidation != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text(emailValidation ?? passwordValidation!),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        return;
                      }

                      try {
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Registration successful!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyHomePage()),
                        );
                      } catch (error) {
                        print("Error during registration: $error");
                      }
                    },
                    child: Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
