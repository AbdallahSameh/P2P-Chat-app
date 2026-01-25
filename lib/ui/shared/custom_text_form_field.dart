import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText, hintText;
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a valid $labelText';
        }
        return null;
      },
      cursorColor: Colors.indigo,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.indigo, width: 1.5),
        ),
        label: Text(
          labelText,
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        ),
        hint: Text(
          hintText,
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
