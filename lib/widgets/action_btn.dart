import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: null,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.black),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ));
  }
}
