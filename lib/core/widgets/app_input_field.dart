import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppInputField extends StatelessWidget {
  final String? hint;
  final String? labeltext;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool isDropdown;
  final List<String>? dropdownItems;
  final String? value;
  final TextEditingController? controller;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureTexts;

  const AppInputField({
    this.hint,
    this.labeltext,
    this.onChanged,
    this.keyboardType,
    this.isDropdown = false,
    this.dropdownItems,
    this.value,
    this.controller,
    this.maxLength,
    this.inputFormatters,

    Key? key, required this.obscureTexts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
         color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        obscureText: obscureTexts,
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 16, color: Color(0xFF212B36)),
        decoration: InputDecoration(
          hintText: hint,
          labelText: labeltext,
          hintStyle:  TextStyle(
             color: Theme.of(context).colorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:  BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:  BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:  BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          filled: true,
          fillColor:Theme.of(context).colorScheme.secondary,
          counterText: '',
        ),
      ),
    );
  }
}
