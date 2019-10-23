import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    Key key,
    @required this.label,
    this.controller,
    this.obscureText = false,
  }) : super(key: key);

  final String label;
  final bool obscureText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(fontSize: 14),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextField(
            obscureText: obscureText,
            controller: controller,
            decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white),
          ),
        ),
      ],
    );
  }
}
