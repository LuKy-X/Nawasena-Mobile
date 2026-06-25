import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/extensions/context_ext.dart';
import 'package:nawasena/core/widgets/mascot_widget.dart';
import 'package:nawasena/core/widgets/nawasena_button.dart';
import 'package:nawasena/features/auth/providers/auth_provider.dart';
import 'package:nawasena/features/auth/widgets/auth_text_field.dart';
import 'package:nawasena/features/home/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  final _classCodeCtrl = TextEditingController();
  bool _showClassCode  = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    _classCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name:                 _nameCtrl.text.trim(),
      email:                _emailCtrl.text.trim(),
      password:             _passCtrl.text,
      passwordConfirmation: _confirmCtrl.text,
      classCode:            _showClassCode ? _classCodeCtrl.text.trim() : null,
    );
    if (!mounted) return;
    if (success) {
      context.pushAndRemoveUntil(const HomeScreen());
    } else {
      context.showSnack(auth.errorMessage ?? 'Pendaftaran gagal.', isError: true);
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: context.pop,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.softShadow,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.darkText),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Buat Akun',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mulai perjalanan budayamu!',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const MascotWidget(pose: MascotPose.pointing, size: 90),
                ],
              ),
              const SizedBox(height: 24),

              // ── Form Card ───────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthTextField(
                        controller: _nameCtrl,
                        hint: 'Nama lengkap kamu',
                        prefixIcon: Icons.person_outline,
                        validator: (v) => (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 14),
                      AuthTextField(
                        controller:  _emailCtrl,
                        hint:        'Alamat email',
                        prefixIcon:  Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                          if (!v.contains('@')) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AuthTextField(
                        controller: _passCtrl,
                        hint: 'Password (min. 8 karakter)',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                          if (v.length < 8) return 'Password minimal 8 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AuthTextField(
                        controller: _confirmCtrl,
                        hint: 'Konfirmasi password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        textInputAction: _showClassCode ? TextInputAction.next : TextInputAction.done,
                        validator: (v) {
                          if (v != _passCtrl.text) return 'Password tidak cocok';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Toggle Kode Kelas (opsional B2B) ───────────────
                      GestureDetector(
                        onTap: () => setState(() => _showClassCode = !_showClassCode),
                        child: Row(
                          children: [
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 200),
                              turns: _showClassCode ? 0.25 : 0,
                              child: const Icon(Icons.arrow_right_rounded,
                                  color: AppColors.primaryOrange),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Punya kode kelas dari guru?',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: _showClassCode
                            ? Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: AuthTextField(
                                  controller:     _classCodeCtrl,
                                  hint:           'Kode kelas (contoh: JWA-ABC12)',
                                  prefixIcon:     Icons.class_outlined,
                                  textInputAction: TextInputAction.done,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 24),

                      Consumer<AuthProvider>(
                        builder: (_, auth, __) => NawasenaButton(
                          label:     'Daftar Sekarang',
                          onPressed: auth.isLoading ? null : _register,
                          isLoading: auth.isLoading,
                          color:     AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Info XP Selamat Datang ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.xpBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.xpBlue.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Text('🎁', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Daftar sekarang dan dapatkan\n5 nyawa + streak awal!',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          color: AppColors.xpBlueDark,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
