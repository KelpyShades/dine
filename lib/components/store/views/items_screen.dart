import 'package:dine/components/store/data/models/menu_item_model.dart';
import 'package:dine/components/store/provider/provider.dart';
import 'package:dine/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

final countProvider = StateProvider.autoDispose<int>((ref) {
  return 1;
});

class ItemsScreen extends ConsumerStatefulWidget {
  final MenuItem item;
  const ItemsScreen({super.key, required this.item});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        actionsPadding: const EdgeInsets.only(right: 30),
        scrolledUnderElevation: 0,
        leadingWidth: 55,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Container(
              margin: const EdgeInsets.only(left: 30),
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              context.pushReplacement('/cart');
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.shopping_cart_rounded, size: 18),
                ),
                if (cartItems.isNotEmpty)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Consumer(
                          builder: (context, ref, child) {
                            final cartList = ref.watch(cartProvider);
                            return Text(
                              cartList.length.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    spacing: 20,
                    children: [
                      Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(widget.item.imageUrl),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 5,
                              children: [
                                Text(
                                  widget.item.category.name == "meal"
                                      ? "Meal"
                                      : widget.item.category.name == "dessert"
                                      ? "Dessert"
                                      : widget.item.category.name == "drink"
                                      ? "Drink"
                                      : "Snack",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.orange,
                                  ),
                                ),
                                Text(
                                  widget.item.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 5,
                              children: [
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 5,
                              children: [
                                Text(
                                  'Vendor',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 2,
                                  children: [
                                    ref
                                        .watch(vendorProvider)
                                        .maybeWhen(
                                          data: (vendors) {
                                            final vendor = vendors.firstWhere(
                                              (e) =>
                                                  e.id == widget.item.vendorId,
                                              orElse: () => vendors.first,
                                            );
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              spacing: 2,
                                              children: [
                                                Text(
                                                  vendor.name!,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Row(
                                                  spacing: 2,
                                                  children: [
                                                    Icon(
                                                      Icons.location_on_rounded,
                                                      size: 14,
                                                      color: Colors.black,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        vendor.location!,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  spacing: 2,
                                                  children: [
                                                    Icon(
                                                      Icons.phone_rounded,
                                                      size: 14,
                                                      color: Colors.black,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        vendor.phone!,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                          orElse: () => Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            spacing: 2,
                                            children: [
                                              Text(
                                                'Loading vendor...',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.black,
                        ),
                        onPressed: () {
                          if (ref.read(countProvider) > 1) {
                            ref.read(countProvider.notifier).state--;
                          }
                        },
                        icon: Icon(Icons.remove_rounded),
                      ),
                      Text(
                        ref.watch(countProvider).toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.orange,
                        ),
                        onPressed: () {
                          ref.read(countProvider.notifier).state++;
                        },
                        icon: Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 100,
                    width: double.infinity,
                    // color: AppColors.lightGreen,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "GHC ${widget.item.price}",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.orange,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final count = ref.read(countProvider);

                            for (var i = 0; i < count; i++) {
                              ref.read(cartProvider.notifier).state = [
                                ...ref.read(cartProvider),
                                widget.item,
                              ];
                            }
                            ref.read(countProvider.notifier).state = 1;
                          },
                          child: Container(
                            height: 40,
                            width: 150,
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 5,
                              children: [
                                Icon(
                                  Icons.shopping_cart_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Add to Cart",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
