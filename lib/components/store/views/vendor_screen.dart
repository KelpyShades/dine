import 'package:dine/components/store/data/models/vendor_models.dart';
import 'package:dine/components/store/provider/provider.dart';
import 'package:dine/core/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VendorScreen extends ConsumerStatefulWidget {
  final Vendor vendor;
  const VendorScreen({super.key, required this.vendor});

  @override
  ConsumerState<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends ConsumerState<VendorScreen> {
  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final menuItemsAsync = ref.watch(menuItemProvider);

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
                spacing: 15,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.vendor.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              spacing: 16,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 2,
                                    children: [
                                      Text(
                                        widget.vendor.name!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 24,
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
                                              widget.vendor.location!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
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
                                              widget.vendor.phone!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Menu',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    menuItemsAsync.when(
                                      loading: () => Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(32),
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      error: (error, stack) => Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(32),
                                          child: Text('Error loading menu'),
                                        ),
                                      ),
                                      data: (menuItems) {
                                        final vendorMenu = menuItems
                                            .where(
                                              (item) =>
                                                  item.vendorId ==
                                                  widget.vendor.id,
                                            )
                                            .toList();

                                        if (vendorMenu.isEmpty) {
                                          return Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(32),
                                              child: Text(
                                                'No menu items available',
                                              ),
                                            ),
                                          );
                                        }

                                        return GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 0.75,
                                                mainAxisSpacing: 10,
                                                crossAxisSpacing: 10,
                                              ),
                                          itemCount: vendorMenu.length,
                                          itemBuilder: (context, index) =>
                                              ItemCard(item: vendorMenu[index]),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                // searched item list
                              ],
                            ),
                          ),
                        );
                      },
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
