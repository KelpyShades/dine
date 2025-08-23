import 'package:dine/components/store/data/models/menu_item_model.dart';
import 'package:dine/components/store/data/models/vendor_models.dart';
import 'package:dine/components/store/provider/provider.dart';
import 'package:dine/core/snackbar.dart';
import 'package:dine/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

// Availability toggle provider for menu items
final itemAvailabilityProvider = StateProvider.family<bool, String>((
  ref,
  itemId,
) {
  return true; // Default availability state
});

class VendorMenuScreen extends ConsumerWidget {
  const VendorMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the underlying async menu data
    final menuItemsAsync = ref.watch(menuItemProvider);
    final vendor = ref.watch(currentVendorProvider);
    final menuItems = ref.watch(vendorMenuItemsProvider(vendor!.id));
    final menuStats = ref.watch(vendorMenuStatsProvider(vendor.id));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Menu Items',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leadingWidth: 45,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              margin: const EdgeInsets.only(left: 15),
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
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: menuItemsAsync.when(
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.orange),
                SizedBox(height: 16),
                Text(
                  'Loading menu items...',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                SizedBox(height: 16),
                Text(
                  'Failed to load menu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Please check your connection and try again',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
          data: (_) => Column(
            children: [
              // Stats Overview
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  spacing: 12,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Menu Overview',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    // Stats Cards
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${menuStats['total']}',
                            'Total Items',
                            Colors.blue,
                            Icons.restaurant_menu,
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            '${menuStats['available']}',
                            'Available',
                            Colors.green,
                            Icons.check_circle_outline,
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            '${menuStats['unavailable']}',
                            'Out of Stock',
                            Colors.red,
                            Icons.block,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Divider
              Container(height: 1, color: Colors.grey[200]),

              // Menu Items List
              Expanded(
                child: menuItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: menuItems.length,
                        itemBuilder: (context, index) {
                          final item = menuItems[index];
                          return _buildMenuItemCard(item, ref, context);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-menu-item', extra: vendor);
        },
        backgroundColor: AppColors.orange,
        tooltip: 'Add Menu Item',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 8,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),

          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(
    MenuItem item,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Item Header with Image and Basic Info
          Container(
            padding: EdgeInsets.all(12),
            child: Row(
              spacing: 12,
              children: [
                // Item Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      // Name and Availability
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.isAvailable
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.isAvailable ? 'Available' : 'Out of Stock',
                              style: TextStyle(
                                fontSize: 10,
                                color: item.isAvailable
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Category and Price
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.category.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            'GHC ${item.price}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      ),

                      // Description
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              spacing: 8,
              children: [
                // Tags
                if (item.tags.isNotEmpty)
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      children: item.tags.take(2).map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Toggle Availability Button
                GestureDetector(
                  onTap: () => _toggleAvailability(item, ref, context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isAvailable
                          ? Colors.orange[100]
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.isAvailable ? 'Hide' : 'Show',
                      style: TextStyle(
                        fontSize: 10,
                        color: item.isAvailable
                            ? Colors.orange[700]
                            : Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Delete Button
                GestureDetector(
                  onTap: () => _showDeleteDialog(item, ref, context),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          Text(
            'No Menu Items Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'Tap the + button to add your first menu item',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _toggleAvailability(
    MenuItem item,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final updatedItem = item.copyWith(isAvailable: !item.isAvailable);
    final vendorMenuNotifier = ref.read(vendorMenuProvider.notifier);

    await vendorMenuNotifier.updateMenuItem(updatedItem, context: context);
  }

  void _showDeleteDialog(MenuItem item, WidgetRef ref, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Menu Item',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () {
                _deleteMenuItem(item, ref, context);
                Navigator.of(context).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  customSnackbar(
                    '${item.name} deleted successfully',
                    type: SnackType.success,
                    context: context,
                  );
                });
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteMenuItem(
    MenuItem item,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final vendorMenuNotifier = ref.read(vendorMenuProvider.notifier);

    await vendorMenuNotifier.deleteMenuItem(item.id, context: context);
  }
}
