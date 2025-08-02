import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  const SearchBar({super.key, required this.hintText, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
