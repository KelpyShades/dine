import 'package:dine/components/store/data/models/menu_item_model.dart';
import 'package:dine/components/store/provider/provider.dart';
import 'package:dine/core/theme.dart';
import 'package:dine/core/widgets/category_card.dart';
import 'package:dine/core/widgets/featured_food_card.dart';
import 'package:dine/core/widgets/item_card.dart';
import 'package:dine/core/widgets/search_bar.dart';
import 'package:dine/core/widgets/vendor_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';

//snacks, drinks, desserts, meals,

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  @override
  Widget build(BuildContext context) {
    // Using new async providers directly
    final menuItemsAsync = ref.watch(menuItemProvider);
    final vendorsAsync = ref.watch(vendorProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final cartItems = ref.watch(cartProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    // Use computed filtered providers for search results
    final filteredItems = ref.watch(filteredMenuItemsProvider);
    final filteredVendors = ref.watch(filteredVendorsProvider);
    return Scaffold(
      // backgroundColor: AppColors.lightGreen,
      appBar: AppBar(
        backgroundColor: AppColors.orange,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Image.asset('assets/images/logo.png', height: 40, width: 40),
        ),
        // title: const Text('Home'),
        actionsPadding: const EdgeInsets.only(right: 30),
        actions: [
          Row(
            spacing: 10,
            children: [
              GestureDetector(
                onTap: () {
                  context.push('/cart');
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
                            child: Text(
                              cartItems.length.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.push('/vendor-auth');
                },
                child: Container(
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
                  child: Icon(Icons.store_rounded, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          spacing: 10,
          children: [
            // Fixed search bar at the top
            Container(
              width: double.infinity,
              height: 75,
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [Search()],
                ),
              ),
            ),

            // Search results section
            if (searchQuery.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    spacing: 16,
                    children: [
                      // Filtered Vendors
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Text(
                            'Restaurants',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (filteredVendors.isNotEmpty)
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: filteredVendors.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: VendorCard(
                                    vendor: filteredVendors[index],
                                  ),
                                ),
                              ),
                            ),
                          if (filteredVendors.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('No restaurants found'),
                              ),
                            ),
                        ],
                      ),

                      // Filtered Menu Items
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Text(
                            'Food Items',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (filteredItems.isNotEmpty)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                  ),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) =>
                                  ItemCard(item: filteredItems[index]),
                            ),
                          if (filteredItems.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text('No food items found'),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Main content with async state handling
            if (searchQuery.isEmpty)
              Expanded(
                child: menuItemsAsync.when(
                  loading: () => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.orange),
                        SizedBox(height: 16),
                        Text(
                          'Loading delicious food...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please check your connection and try again',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              ref.read(menuItemProvider.notifier).refresh(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (menuItems) {
                    // Handle empty state when no menu items available
                    if (menuItems.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No Menu Items Available',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Check back later for delicious options!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  ref.read(menuItemProvider.notifier).refresh(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Refresh'),
                            ),
                          ],
                        ),
                      );
                    }

                    final menuItemList =
                        menuItems.where((e) => e.isAvailable == true).toList()
                          ..reversed;

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        spacing: 16,
                        children: [
                          // Featured food carousel
                          if (menuItemList.isNotEmpty)
                            CarouselSlider.builder(
                              options: CarouselOptions(
                                height: 200.0,
                                aspectRatio: 16 / 9,
                                viewportFraction: 0.95,
                                initialPage: 1,
                                enableInfiniteScroll: true,
                                reverse: false,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 5),
                                autoPlayAnimationDuration: Duration(
                                  milliseconds: 2000,
                                ),
                                autoPlayCurve: Curves.easeInOut,
                                enlargeCenterPage: true,
                                enlargeFactor: 0.25,
                                scrollDirection: Axis.horizontal,
                              ),
                              itemCount: menuItemList.length.clamp(0, 5),
                              itemBuilder:
                                  (
                                    BuildContext context,
                                    int itemIndex,
                                    int pageViewIndex,
                                  ) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FeaturedFoodCard(
                                        menuItem: menuItemList[itemIndex],
                                      ),
                                    );
                                  },
                            ),

                          // Category cards
                          Row(
                            spacing: 5,
                            children: [
                              CategoryCard(name: 'All'),
                              CategoryCard(name: 'Meal'),
                              CategoryCard(name: 'Drink'),
                              CategoryCard(name: 'Dessert'),
                              CategoryCard(name: 'Snack'),
                            ],
                          ),

                          // Featured vendors with async handling
                          vendorsAsync.maybeWhen(
                            data: (vendors) {
                              final openVendors = vendors
                                  .where((v) => v.isOpen && v.name != null)
                                  .toList();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Featured Restaurants',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (openVendors.isNotEmpty)
                                    SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: openVendors.length,
                                        itemBuilder: (context, index) =>
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: VendorCard(
                                                vendor: openVendors[index],
                                              ),
                                            ),
                                      ),
                                    ),
                                  if (openVendors.isEmpty)
                                    Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Text('No restaurants available'),
                                      ),
                                    ),
                                ],
                              );
                            },
                            orElse: () => SizedBox.shrink(),
                          ),

                          // Food categories with local filtering based on selected category
                          if (selectedCategory == Category.all)
                            // Show all categories when 'All' is selected
                            ...Category.values
                                .where((cat) => cat != Category.all)
                                .map((category) {
                                  final categoryItems = menuItems
                                      .where(
                                        (item) =>
                                            item.category == category &&
                                            item.isAvailable,
                                      )
                                      .toList();

                                  if (categoryItems.isEmpty) {
                                    return SizedBox.shrink();
                                  }

                                  return Column(
                                    spacing: 16,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 230,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: categoryItems.length,
                                          itemBuilder: (context, index) =>
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: ItemCard(
                                                  item: categoryItems[index],
                                                ),
                                              ),
                                        ),
                                      ),
                                    ],
                                  );
                                })
                          else
                            // Show only the selected category
                            () {
                              final categoryItems = menuItems
                                  .where(
                                    (item) =>
                                        item.category == selectedCategory &&
                                        item.isAvailable,
                                  )
                                  .toList();

                              if (categoryItems.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(40),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.restaurant_menu_outlined,
                                          size: 60,
                                          color: Colors.grey[300],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'No ${selectedCategory!.name} items available',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  spacing: 16,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedCategory!.name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 230,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: categoryItems.length,
                                        itemBuilder: (context, index) =>
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: ItemCard(
                                                item: categoryItems[index],
                                              ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }(),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
