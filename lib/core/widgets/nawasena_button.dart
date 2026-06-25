import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';
import 'package:nawasena/core/widgets/bouncy_tap.dart';

/// Tombol utama Nawasena dengan efek 3D Duolingo-style.
/// Memiliki "shadow bawah" yang tebal sehingga terlihat seperti tombol fisik.
class NawasenaButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double borderRadius;
  final double height;
  final Widget? child;

  const NawasenaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color     = AppColors.primaryOrange,
    this.textColor = Colors.white,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.borderRadius = 18,
    this.height = 56,
    this.child,
  });

  const NawasenaButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.color     = AppColors.primaryOrange,
    this.textColor = AppColors.primaryOrange,
    this.isLoading = false,
    this.borderRadius = 18,
    this.height = 56,
    this.child,
  })  : isOutlined = true,
        icon = null;

  @override
  State<NawasenaButton> createState() => _NawasenaButtonState();
}

class _NawasenaButtonState extends State<NawasenaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final effectiveColor = isDisabled
        ? AppColors.lockedGrey
        : (widget.isOutlined ? Colors.white : widget.color);
    final shadowColor = isDisabled
        ? const Color(0xFF999999)
        : Color.lerp(widget.color, Colors.black, 0.3)!;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        child: Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.isOutlined
                ? Border.all(
                    color: isDisabled ? AppColors.lockedGrey : widget.color,
                    width: 2.5,
                  )
                : null,
            boxShadow: _pressed || isDisabled
                ? []
                : [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 0,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(
                      widget.isOutlined ? widget.color : Colors.white,
                    ),
                  ),
                )
              : widget.child ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: widget.textColor, size: 20),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: isDisabled
                            ? Colors.white
                            : (widget.isOutlined ? widget.color : widget.textColor),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Tombol Google SSO dengan logo dan style khusus
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return NawasenaButton(
      label: 'Masuk dengan Google',
      onPressed: onPressed,
      color: Colors.white,
      textColor: AppColors.darkText,
      isLoading: isLoading,
      child: isLoading
          ? const SizedBox(
              width: 22, height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  alignment: Alignment.center,
                  // Menggunakan teks "G" sebagai pengganti aset Google logo
                  child: const Text(
                    'G',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Masuk dengan Google',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
    );
  }
}
