// lib/core/widgets/custom_bottom_nav.dart
//
// Bottom nav adaptif: dark style saat tab Beranda (index 0), terang di tab lain.
import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int              currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Icons.home_rounded,        label: 'Beranda'),
    (icon: Icons.leaderboard_rounded, label: 'Peringkat'),
    (icon: Icons.assignment_rounded,  label: 'Tugas'),
    (icon: Icons.store_rounded,       label: 'Toko'),
    (icon: Icons.person_rounded,      label: 'Profil'),
  ];

  // Dark saat tab Beranda
  // bool get _isDark => currentIndex == 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _items.length,
          (i) => _NavItem(
            icon:     _items[i].icon,
            label:    _items[i].label,
            isActive: currentIndex == i,
            onTap:    () => onTap(i),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final bool         isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor   = AppColors.primaryOrange;
    final inactiveColor = AppColors.lockedGrey;
    final color         = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                color:      color,
                fontSize:   10,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
