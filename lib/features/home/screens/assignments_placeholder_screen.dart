import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/widgets/mascot_widget.dart';
import 'package:nawasena/features/auth/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:nawasena/features/auth/providers/auth_provider.dart';

/// Placeholder Assignments yang menampilkan teks sesuai role user.
/// Akan digantikan oleh AssignmentsScreen B2B di sprint berikutnya.
class AssignmentsPlaceholderScreen extends StatelessWidget {
  const AssignmentsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isB2b = user?.isB2b ?? false;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MascotWidget(
                  pose: MascotPose.pointing,
                  size: 150,
                  animate: true,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Penugasan',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isB2b
                      ? 'Fitur tugas B2B sedang disiapkan.\nHubungi gurumu untuk informasi lebih lanjut.'
                      : 'Bergabunglah ke kelas dari gurumu untuk\nmendapatkan tugas dan tantangan!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    color: AppColors.mediumText,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🏗️', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Modul B2B (Guru & Siswa)\nsegera hadir!',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBrown,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
