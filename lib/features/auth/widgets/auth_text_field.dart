import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.isPassword       = false,
    this.keyboardType     = TextInputType.text,
    this.validator,
    this.textInputAction  = TextInputAction.next,
    this.onEditingComplete,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:           widget.controller,
      obscureText:          widget.isPassword && _obscure,
      keyboardType:         widget.keyboardType,
      textInputAction:      widget.textInputAction,
      onEditingComplete:    widget.onEditingComplete,
      validator:            widget.validator,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: AppColors.darkText,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(widget.prefixIcon, color: AppColors.lockedGrey, size: 20),
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.lockedGrey,
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }
}
