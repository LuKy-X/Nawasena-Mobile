import 'package:flutter/material.dart';
import 'package:nawasena/app/nawasena_app.dart';

/// Entry point aplikasi Nawasena.
///
/// Hal-hal yang dilakukan di sini:
/// 1. ensureInitialized() — wajib sebelum memanggil plugin apapun secara async
/// 2. Inisialisasi minimal lain jika diperlukan (Firebase, dll.)
/// 3. Jalankan NawasenaApp
///
/// Google Sign-In TIDAK diinisialisasi di sini karena AuthRepository.signInWithGoogle()
/// memanggil GoogleSignIn.instance.initialize() yang bersifat idempotent —
/// aman dipanggil berulang kali dan hanya melakukan inisialisasi sekali.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NawasenaApp());
}
