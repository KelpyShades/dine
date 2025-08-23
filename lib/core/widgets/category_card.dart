import 'package:dine/components/store/data/models/menu_item_model.dart';
import 'package:dine/components/store/provider/provider.dart';
import 'package:dine/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryCard extends ConsumerStatefulWidget {
  final String name;
  const CategoryCard({super.key, required this.name});

  @override
  ConsumerState<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends ConsumerState<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).state = Category.values
            .byName(widget.name.toLowerCase());
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(minWidth: 60, minHeight: 60),
        decoration: BoxDecoration(
          color:
              (widget.name.toLowerCase() == 'all' &&
                      selectedCategory == null) ||
                  (selectedCategory != null &&
                      selectedCategory ==
                          Category.values.byName(widget.name.toLowerCase()))
              ? AppColors.orange
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.orange.withAlpha(100),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // icon
            Image.asset(
              'assets/images/${widget.name.toLowerCase()}.png',
              width: 20,
              height: 20,
            ),
            // text
            Text(
              widget.name,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}


// meal, drink. dessert, snack, other , all