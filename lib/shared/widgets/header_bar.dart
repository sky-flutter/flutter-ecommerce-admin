import 'package:flutter/material.dart';

class HeaderBar extends StatelessWidget {
  final String title;
  final VoidCallback onLogout;
  const HeaderBar({super.key, required this.title, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: onLogout,
        ),
      ],
    );
  }
}
