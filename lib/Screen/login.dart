import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_downloader/Screen/register.dart';
import 'package:video_downloader/Screen/video.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isPasswordVisible = false; // Added state for password visibility

  bool isPasswordVisible = false; // Added state for password visibility
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Load the asset video as bytes
      ByteData assetByteData = await rootBundle.load('asset/video/status.mp4');
      Uint8List bytes = assetByteData.buffer.asUint8List();

      firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;
      firebase_storage.Reference ref = storage.ref().child("videos/video.mp4");

      Directory tempDir = await getTemporaryDirectory();
      String filePath = path.join(tempDir.path, "video.mp4");
      File file = File(filePath);
      await file.writeAsBytes(bytes);

      if (await file.exists()) {
        ref.putFile(file).then((task) async {
          String downloadUrl = await task.ref.getDownloadURL();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPage(downloadUrl: downloadUrl),
            ),
          );
        });
      } else {
        print("File does not exist at path: $filePath");
      }
    } catch (error) {
      print("Error during login and video upload: $error");
      // ... Rest of error handling code ...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                  obscureText: !_isPasswordVisible,
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: _togglePasswordVisibility,
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add your login logic here
                      _login();
                    },
                    child: const Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const registerPage()),
                      );
                    },
                    child: const Text('Register'),
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
