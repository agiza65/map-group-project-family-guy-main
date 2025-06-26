import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;
  final VoidCallback onTap;

  const ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    this.highlight = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: highlight
                ? const Color(0xFFC6F5C6)
                : const Color(0xFFE7F9E7),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }
}
