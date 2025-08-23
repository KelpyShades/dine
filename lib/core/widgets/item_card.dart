import 'package:dine/components/store/data/models/menu_item_model.dart';
import 'package:dine/components/store/provider/provider.dart';
import 'package:dine/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ItemCard extends ConsumerWidget {
  final MenuItem item;
  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        context.push('/item', extra: item);
      },
      child: Container(
        width: 200,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(100),
              spreadRadius: 2,
              blurRadius: 7,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 250,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(item.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    // color: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                if (!item.isAvailable)
                  Container(
                    width: 250,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(200),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: item.isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      item.isAvailable ? 'Available' : 'Not Available',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    item.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Icon(Icons.store_rounded, size: 10, color: Colors.grey),
                      Expanded(
                        child: ref
                            .watch(vendorProvider)
                            .maybeWhen(
                              data: (vendors) {
                                final vendor = vendors.firstWhere(
                                  (e) => e.id == item.vendorId,
                                  orElse: () => vendors.first,
                                );
                                return Text(
                                  vendor.name!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                              orElse: () => Text(
                                'Loading...',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "GHC ${item.price}",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).state = [
                            ...ref.read(cartProvider),
                            item,
                          ];
                        },
                        child: Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.shopping_cart_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              Text(
                                'Add',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
