// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/widgets/custom_bottom_nav.dart';
import 'package:nawasena/core/widgets/mascot_widget.dart';
import 'package:nawasena/features/auth/providers/auth_provider.dart';
import 'package:nawasena/features/home/models/course_model.dart';
import 'package:nawasena/features/home/providers/home_provider.dart';
import 'package:nawasena/features/home/screens/lesson_detail_screen.dart';
import 'package:nawasena/features/home/screens/assignments_placeholder_screen.dart';
import 'package:nawasena/features/home/widgets/game_app_bar.dart';
import 'package:nawasena/features/home/widgets/game_learning_path.dart';
import 'package:nawasena/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:nawasena/features/shop/screens/shop_screen.dart';
import 'package:nawasena/features/profile/screens/profile_screen.dart';

// const kGameBg = Colors.white;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const SizedBox.shrink();


    final pages = [
      const _BerandaTab(),
      const LeaderboardScreen(),
      const AssignmentsPlaceholderScreen(),
      const ShopScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ── Tab Beranda ───────────────────────────────────────────────────────────────
class _BerandaTab extends StatelessWidget {
  const _BerandaTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          GameAppBar(user: user),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.successGreen,
              backgroundColor: Colors.white,
              onRefresh: () =>
                  context.read<HomeProvider>().loadCourses(forceRefresh: true),
              child: Consumer<HomeProvider>(
                builder: (context, hp, _) {
                  if (hp.isLoading) {
                    return const Center(child: _GameLoading());
                  }
                  if (hp.state == HomeLoadState.error) {
                    return _GameError(
                      message: hp.error ?? 'Gagal memuat.',
                      onRetry: () => hp.loadCourses(forceRefresh: true),
                    );
                  }
                  if (hp.courses.isEmpty) return const _GameEmpty();

                  return GameLearningPath(
                    courses: hp.courses,
                    onLessonTap: (lesson) {
                      if (lesson.status == LessonStatus.locked) return;
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => LessonDetailScreen(lesson: lesson),
                      ));
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── State widgets ─────────────────────────────────────────────────────────────
class _GameLoading extends StatelessWidget {
  const _GameLoading();
  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      MascotWidget(pose: MascotPose.thinking, size: 100, animate: true),
      SizedBox(height: 16),
      Text('Memuat peta belajar...', style: TextStyle(
        fontFamily: 'Nunito', fontWeight: FontWeight.w700,
        fontSize: 15, color: Colors.white60,
      )),
    ],
  );
}

class _GameError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _GameError({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const MascotWidget(pose: MascotPose.thinking, size: 100),
      const SizedBox(height: 12),
      Text(message, textAlign: TextAlign.center, style: const TextStyle(
        color: Colors.white60, fontFamily: 'Nunito', fontWeight: FontWeight.w600,
      )),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Coba Lagi'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successGreen,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ]),
  ));
}

class _GameEmpty extends StatelessWidget {
  const _GameEmpty();
  @override
  Widget build(BuildContext context) => const Center(
    child: MascotWidget(
      pose: MascotPose.searching, size: 120, animate: true,
      speechText: 'Kursus belum tersedia!',
    ),
  );
}
