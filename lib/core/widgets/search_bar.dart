import 'package:dine/components/store/provider/provider.dart';
import 'package:dine/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Search extends ConsumerStatefulWidget {
  const Search({super.key});

  @override
  ConsumerState<Search> createState() => _SearchState();
}

class _SearchState extends ConsumerState<Search> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.text,
      // textInputAction: TextInputAction.search,
      // onSubmitted: (value) {},
      onChanged: (value) {
        ref.read(searchQueryProvider.notifier).state = value;
      },
      decoration: InputDecoration(
        hintText: 'Search for food',
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 40),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        fillColor: Colors.white,
        filled: true,
        prefixIcon: const Icon(Icons.search, size: 20),
      ),
    );
  }
}
