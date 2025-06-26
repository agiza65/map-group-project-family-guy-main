import 'package:flutter/material.dart';

Future<void> showInfoDialog(
  BuildContext context,
  String title,
  String message, {
  String buttonText = "OK",
  VoidCallback? onPressed,
}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title, style: const TextStyle(fontSize: 22)),
      content: Text(message, style: const TextStyle(fontSize: 20)),
      actions: [
        TextButton(
          onPressed: onPressed ?? () => Navigator.pop(context),
          child: Text(buttonText, style: const TextStyle(fontSize: 20)),
        ),
      ],
    ),
  );
}
