import 'package:flutter/material.dart';

class Password extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const Password({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      obscureText: true,
      decoration: InputDecoration(
        labelText: "Contraseña",
        prefixIcon: Icon(Icons.lock),
        suffixIcon: Icon(Icons.visibility),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
