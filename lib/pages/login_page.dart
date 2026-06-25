import 'package:flutter/material.dart';
import '../services/auth_service.dart'; 

class LoginPage extends StatelessWidget {
  // Terima instance AuthService yang dilempar dari main.dart
  final AuthService authService;

  const LoginPage({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Nawasena'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Selamat Datang di Nawasena',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text("Masuk dengan Google"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Tombol full width
                ),
                onPressed: () async {
                  // Langsung panggil fungsi authenticate saat tombol ditekan
                  await authService.signInWithGoogle();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}