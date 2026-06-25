import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  // 1. Fungsi untuk Inisialisasi awal (Wajib di versi 7)
  Future<void> initGoogleSignIn() async {
    // Menggunakan singleton instance dan memanggil initialize()
    await GoogleSignIn.instance.initialize(
      serverClientId: '427236973627-l9pe2ccanbgn2eqiobdbailm8bprrhi0.apps.googleusercontent.com',
    );
  }

  // 2. Fungsi utama untuk memproses Login
  Future<void> signInWithGoogle() async {
    try {
      // Method signIn() diganti menjadi authenticate() di versi 7
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email', 'profile'], 
      );

      if (googleUser == null) {
        print("Login dibatalkan oleh pengguna.");
        return; 
      }

      // Proses mendapatkan token tetap sama
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        print("Berhasil mendapatkan idToken! Ini tokennya: \n$idToken");
        await _sendTokenToLaravel(idToken);
      }

    } catch (error) {
      print("Terjadi kesalahan saat Google Sign In: $error");
    }
  }

  // 3. Fungsi untuk mengirim token ke Backend Laravel
  Future<void> _sendTokenToLaravel(String idToken) async {
    final Uri url = Uri.parse('http://10.0.2.2:8000/api/auth/google/callback'); 

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Login sukses dari Laravel! Token: ${data['access_token']}");
      } else {
        print("Gagal verifikasi di Laravel: ${response.body}");
      }
    } catch (e) {
      print("Tidak bisa terhubung ke server: $e");
    }
  }
}