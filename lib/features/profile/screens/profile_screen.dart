import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/extensions/context_ext.dart';
import 'package:nawasena/core/widgets/mascot_widget.dart';
import 'package:nawasena/core/widgets/nawasena_button.dart';
import 'package:nawasena/features/auth/models/user_model.dart';
import 'package:nawasena/features/auth/providers/auth_provider.dart';
import 'package:nawasena/features/auth/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Profile Header (SliverAppBar) ────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primaryOrange,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHero(user: user),
            ),
            actions: [
              IconButton(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Keluar',
              ),
            ],
          ),

          // ── Stats Cards ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _StatsGrid(user: user),
            ),
          ),

          // ── Menu Items ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('Akun'),
                  _MenuItem(icon: Icons.person_outline, label: 'Edit Profil',
                      onTap: () => _showEditDialog(context, user)),
                  _MenuItem(icon: Icons.lock_outline, label: 'Ubah Password',
                      onTap: () => context.showSnack('Segera hadir!')),
                  _MenuItem(icon: Icons.notifications_outlined, label: 'Notifikasi',
                      onTap: () => context.showSnack('Segera hadir!')),
                  const SizedBox(height: 16),
                  _SectionTitle('Tentang'),
                  _MenuItem(icon: Icons.info_outline, label: 'Tentang Nawasena',
                      onTap: () => context.showSnack('Nawasena v1.0.0')),
                  _MenuItem(icon: Icons.help_outline, label: 'Bantuan & FAQ',
                      onTap: () => context.showSnack('Segera hadir!')),
                  _MenuItem(icon: Icons.privacy_tip_outlined, label: 'Kebijakan Privasi',
                      onTap: () => context.showSnack('Segera hadir!')),
                  const SizedBox(height: 24),
                  NawasenaButton(
                    label: 'Keluar',
                    color: AppColors.primaryRed,
                    onPressed: () => _showLogoutDialog(context),
                    icon: Icons.logout_rounded,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MascotWidget(pose: MascotPose.thinking, size: 80, animate: true),
              const SizedBox(height: 16),
              const Text(
                'Keluar dari Nawasena?',
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900,
                    fontSize: 18, color: AppColors.darkText),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kamu bisa masuk kapan saja lagi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600,
                    fontSize: 14, color: AppColors.mediumText),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: NawasenaButton.outlined(
                  label: 'Batal',
                  onPressed: () => Navigator.pop(context),
                  height: 48,
                )),
                const SizedBox(width: 12),
                Expanded(child: NawasenaButton(
                  label: 'Keluar',
                  color: AppColors.primaryRed,
                  height: 48,
                  onPressed: () async {
                    Navigator.pop(context);
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      context.pushAndRemoveUntil(const LoginScreen());
                    }
                  },
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit Profil',
                  style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900,
                      fontSize: 18, color: AppColors.darkText)),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nama lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: NawasenaButton.outlined(
                  label: 'Batal',
                  onPressed: () => Navigator.pop(context),
                  height: 48,
                )),
                const SizedBox(width: 12),
                Expanded(child: NawasenaButton(
                  label: 'Simpan',
                  height: 48,
                  onPressed: () async {
                    Navigator.pop(context);
                    final auth = context.read<AuthProvider>();
                    final updated = auth.user?.copyWith(name: nameCtrl.text.trim());
                    if (updated != null) auth.updateUser(updated);
                    context.showSnack('Profil berhasil diperbarui!');
                  },
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final UserModel user;
  const _ProfileHero({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.orangeGradient,
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar besar
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 16, offset: const Offset(0, 6),
                  )
                ],
              ),
              child: ClipOval(
                child: user.avatarUrl != null
                    ? CachedNetworkImage(imageUrl: user.avatarUrl!, fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _initials(user.name))
                    : _initials(user.name),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user.name,
              style: const TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w900,
                fontSize: 20, color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _roleLabel(user.role),
                style: const TextStyle(
                  fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                  fontSize: 12, color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initials(String name) => Container(
    color: Colors.white.withOpacity(0.2),
    alignment: Alignment.center,
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : 'N',
      style: const TextStyle(
        fontFamily: 'Nunito', fontWeight: FontWeight.w900,
        fontSize: 36, color: Colors.white,
      ),
    ),
  );

  String _roleLabel(String role) => switch (role) {
    'superadmin'  => '👑 Super Admin',
    'school_admin' => '🏫 Admin Sekolah',
    'teacher'     => '🎓 Guru',
    'student'     => '🎒 Siswa',
    _             => '📚 Pelajar',
  };
}

class _StatsGrid extends StatelessWidget {
  final UserModel user;
  const _StatsGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('⚡', 'XP Total',  '${user.xpTotal}',    AppColors.warningYellow),
      ('🔥', 'Streak',    '${user.streakCount}', const Color(0xFFFF5722)),
      ('❤️', 'Stamina',   user.hasInfiniteHearts ? '∞' : '${user.heartPoints}/100', AppColors.primaryRed),
      ('🪙', 'Koin',      '${user.coins}',       AppColors.warningYellow),
      ('💎', 'Diamond',   '${user.diamonds}',    AppColors.primaryBrown),
      ('🏆', 'Premium',   user.isPremium ? 'Aktif' : 'Gratis', AppColors.successGreen),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.1,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: stats.map((s) => _StatCard(
        emoji: s.$1, label: s.$2, value: s.$3, color: s.$4,
      )).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color  color;
  const _StatCard({required this.emoji, required this.label,
      required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2)),
      boxShadow: AppTheme.cardShadow,
    ),
    alignment: Alignment.center,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900,
                fontSize: 16, color: color)),
        Text(label,
            style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600,
                fontSize: 10, color: AppColors.mediumText)),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
    child: Text(title,
        style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800,
            fontSize: 13, color: AppColors.mediumText, letterSpacing: 0.5)),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final VoidCallback? onTap;
  const _MenuItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderGrey),
      boxShadow: AppTheme.cardShadow,
    ),
    child: ListTile(
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: AppColors.primaryOrange),
      ),
      title: Text(label,
          style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700,
              fontSize: 14, color: AppColors.darkText)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.lockedGrey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
