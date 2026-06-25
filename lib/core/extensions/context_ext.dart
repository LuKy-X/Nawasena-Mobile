import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';

extension ContextExt on BuildContext {
  ThemeData   get theme       => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme   get textTheme   => theme.textTheme;
  double      get screenWidth  => MediaQuery.of(this).size.width;
  double      get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets  get padding      => MediaQuery.of(this).padding;
  bool        get isSmallScreen => screenWidth < 360;

  List<BoxShadow> get softShadow  => AppTheme.softShadow;
  List<BoxShadow> get cardShadow  => AppTheme.cardShadow;

  void showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError ? AppColors.primaryRed : AppColors.successGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  Future<T?> push<T>(Widget page) => Navigator.of(this).push<T>(
    MaterialPageRoute(builder: (_) => page),
  );

  Future<T?> pushReplacement<T>(Widget page) =>
      Navigator.of(this).pushReplacement<T, dynamic>(
        MaterialPageRoute(builder: (_) => page),
      );

  Future<T?> pushAndRemoveUntil<T>(Widget page) =>
      Navigator.of(this).pushAndRemoveUntil<T>(
        MaterialPageRoute(builder: (_) => page),
        (route) => false,
      );
}
