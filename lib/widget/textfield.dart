import 'package:flutter/material.dart';

class MyTextFieldFormWidget extends StatefulWidget {
  String? hintText;
  TextInputType? keyboardType;
  final String? Function(String?)? validator;
  TextEditingController? controller;
  MyTextFieldFormWidget(
      {super.key,
      this.hintText,
      this.controller,
      this.keyboardType,
      this.validator});

  @override
  State<MyTextFieldFormWidget> createState() => _MyTextFieldFormWidgetState();
}

class _MyTextFieldFormWidgetState extends State<MyTextFieldFormWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
