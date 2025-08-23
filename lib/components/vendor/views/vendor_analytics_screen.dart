import 'package:dine/components/store/data/models/menu_item_model.dart';
import 'package:dine/components/store/data/models/order_model.dart';
import 'package:dine/components/store/provider/provider.dart';
import 'package:dine/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VendorAnalyticsScreen extends ConsumerWidget {
  const VendorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(currentVendorProvider);
    // Watch the underlying async data
    final ordersAsync = ref.watch(orderProvider);

    // Get computed stats
    final orderStats = ref.watch(vendorOrderStatsProvider(vendor!.id));
    final menuStats = ref.watch(vendorMenuStatsProvider(vendor.id));
    final vendorOrders = ref.watch(vendorOrdersProvider(vendor.id));
    final vendorMenuItems = ref.watch(vendorMenuItemsProvider(vendor.id));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 55,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: GestureDetector(
            onTap: () => context.pop(),
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
      ),
      body: ordersAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.orange),
              SizedBox(height: 16),
              Text(
                'Loading analytics...',
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
                'Failed to load analytics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Please check your connection and try again',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(orderProvider.notifier).refresh();
                  ref.read(menuItemProvider.notifier).refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
        data: (_) => SingleChildScrollView(
          child: Column(
            spacing: 0,
            children: [
              // Header with gradient background
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(vendor.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      spacing: 4,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.name!,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Business Insights & Performance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        Row(
                          spacing: 6,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            Text(
                              vendor.location!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main Analytics Content
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  spacing: 20,
                  children: [
                    // Quick Stats Overview
                    _buildStatsOverview(orderStats, menuStats),

                    // Revenue & Orders Analytics
                    _buildRevenueSection(vendorOrders, vendor.id),

                    // Menu Performance
                    _buildMenuPerformanceSection(
                      vendorMenuItems,
                      vendorOrders,
                      vendor.id,
                    ),

                    // Category Breakdown
                    _buildCategoryBreakdown(vendorMenuItems),

                    // Recent Performance
                    _buildRecentPerformance(vendorOrders, vendor.id),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the stats overview cards
  Widget _buildStatsOverview(
    Map<String, int> orderStats,
    Map<String, int> menuStats,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.receipt_long,
                  title: 'Total Orders',
                  value: orderStats['total'].toString(),
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.restaurant_menu,
                  title: 'Menu Items',
                  value: menuStats['total'].toString(),
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.pending_actions,
                  title: 'Pending',
                  value: orderStats['pending'].toString(),
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle,
                  title: 'Completed',
                  value: orderStats['completed'].toString(),
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build revenue section
  Widget _buildRevenueSection(List<Order> vendorOrders, String vendorId) {
    final totalRevenue = _calculateTotalRevenue(vendorOrders, vendorId);
    final completedOrders = vendorOrders
        .where((o) => o.orderStatuses[vendorId] == OrderStatus.completed)
        .length;

    // Calculate average order value based on vendor's portion
    double avgOrderValue = 0.0;
    if (completedOrders > 0) {
      double totalVendorValue = 0.0;
      for (final order in vendorOrders.where(
        (o) => o.orderStatuses[vendorId] == OrderStatus.completed,
      )) {
        totalVendorValue += _calculateVendorOrderValue(order, vendorId);
      }
      avgOrderValue = totalVendorValue / completedOrders;
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[50]!, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.trending_up, color: Colors.green, size: 22),
              ),
              SizedBox(width: 12),
              Text(
                'Revenue Analytics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            spacing: 20,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      'Total Revenue',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'GHC ${totalRevenue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      'Avg Order Value',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'GHC ${avgOrderValue.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build menu performance section
  Widget _buildMenuPerformanceSection(
    List<MenuItem> menuItems,
    List<Order> orders,
    String vendorId,
  ) {
    final popularItems = _getPopularItems(menuItems, orders, vendorId);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.star, color: Colors.orange, size: 22),
              ),
              SizedBox(width: 12),
              Text(
                'Top Selling Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (popularItems.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_menu_outlined,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No sales data yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ...popularItems.take(5).map((item) => _buildPopularItemTile(item)),
        ],
      ),
    );
  }

  /// Build popular item tile
  Widget _buildPopularItemTile(MapEntry<MenuItem, int> item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(item.key.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  item.key.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'GHC ${item.key.price}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${item.value} sold',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build category breakdown
  Widget _buildCategoryBreakdown(List<MenuItem> menuItems) {
    final categoryStats = _getCategoryStats(menuItems);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.pie_chart, color: Colors.purple, size: 22),
              ),
              SizedBox(width: 12),
              Text(
                'Menu Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (categoryStats.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No menu items yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...categoryStats.entries.map((entry) => _buildCategoryTile(entry)),
        ],
      ),
    );
  }

  /// Build category tile
  Widget _buildCategoryTile(MapEntry<Category, int> entry) {
    final colors = {
      Category.meal: Colors.red,
      Category.drink: Colors.blue,
      Category.dessert: Colors.pink,
      Category.snack: Colors.green,
    };

    final color = colors[entry.key] ?? Colors.grey;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getCategoryIcon(entry.key), color: color, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.key.name.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            '${entry.value} items',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build recent performance
  Widget _buildRecentPerformance(List<Order> orders, String vendorId) {
    final recentOrders = orders.take(5).toList();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.history, color: Colors.blue, size: 22),
              ),
              SizedBox(width: 12),
              Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (recentOrders.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No recent orders',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...recentOrders.map(
              (order) => _buildRecentOrderTile(order, vendorId),
            ),
        ],
      ),
    );
  }

  /// Build recent order tile
  Widget _buildRecentOrderTile(Order order, String vendorId) {
    final statusColors = {
      OrderStatus.pending: Colors.orange,
      OrderStatus.ready: Colors.blue,
      OrderStatus.completed: Colors.green,
    };

    final orderStatus = order.orderStatuses[vendorId] ?? OrderStatus.pending;

    // Calculate only the vendor's portion of the order
    final vendorItemsTotal = _calculateVendorOrderValue(order, vendorId);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColors[orderStatus],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  order.customerName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 4,
            children: [
              Text(
                'GHC ${vendorItemsTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColors[orderStatus]!.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  orderStatus.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColors[orderStatus],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper methods for calculations
  double _calculateVendorOrderValue(Order order, String vendorId) {
    return order.items.where((item) => item['vendorId'] == vendorId).fold(0.0, (
      sum,
      item,
    ) {
      final subtotal = double.tryParse(item['subtotal'] ?? '0') ?? 0.0;
      return sum + subtotal;
    });
  }

  double _calculateTotalRevenue(List<Order> orders, String vendorId) {
    return orders
        .where(
          (order) => order.orderStatuses[vendorId] == OrderStatus.completed,
        )
        .fold(0.0, (sum, order) {
          // Calculate only the vendor's portion of the order
          final vendorItemsTotal = _calculateVendorOrderValue(order, vendorId);
          return sum + vendorItemsTotal;
        });
  }

  List<MapEntry<MenuItem, int>> _getPopularItems(
    List<MenuItem> menuItems,
    List<Order> orders,
    String vendorId,
  ) {
    final itemCounts = <String, int>{};

    for (final order in orders) {
      for (final item in order.items) {
        final itemId = item['id'] as String? ?? '';
        // Only count items that belong to this vendor
        if (itemId.isNotEmpty && item['vendorId'] == vendorId) {
          itemCounts[itemId] = (itemCounts[itemId] ?? 0) + 1;
        }
      }
    }

    final popularItems = <MapEntry<MenuItem, int>>[];
    for (final item in menuItems) {
      final count = itemCounts[item.id] ?? 0;
      if (count > 0) {
        popularItems.add(MapEntry(item, count));
      }
    }

    popularItems.sort((a, b) => b.value.compareTo(a.value));
    return popularItems;
  }

  Map<Category, int> _getCategoryStats(List<MenuItem> menuItems) {
    final stats = <Category, int>{};
    for (final item in menuItems) {
      stats[item.category] = (stats[item.category] ?? 0) + 1;
    }
    return stats;
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.meal:
        return Icons.restaurant;
      case Category.drink:
        return Icons.local_drink;
      case Category.dessert:
        return Icons.cake;
      case Category.snack:
        return Icons.fastfood;
      default:
        return Icons.restaurant_menu;
    }
  }
}
