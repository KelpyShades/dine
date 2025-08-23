import 'package:dine/components/store/data/models/order_model.dart';
import 'package:dine/components/store/data/models/vendor_models.dart';
import 'package:dine/components/store/provider/provider.dart';
import 'package:dine/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

// Order status filter provider
final orderStatusFilterProvider = StateProvider<OrderStatus?>((ref) {
  return null; // null means show all
});

class VendorOrdersScreen extends ConsumerWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the underlying async order data
    final ordersAsync = ref.watch(orderProvider);
    final vendor = ref.watch(currentVendorProvider);
    final orders = ref.watch(vendorOrdersProvider(vendor!.id));
    final statusFilter = ref.watch(orderStatusFilterProvider);

    // Filter orders based on selected status
    final filteredOrders = statusFilter == null
        ? orders
        : orders
              .where((o) => o.orderStatuses[vendor.id] == statusFilter)
              .toList();

    // Group orders by status
    final pendingOrders = filteredOrders
        .where((o) => o.orderStatuses[vendor.id] == OrderStatus.pending)
        .toList();
    final readyOrders = filteredOrders
        .where((o) => o.orderStatuses[vendor.id] == OrderStatus.ready)
        .toList();
    final completedOrders = filteredOrders
        .where((o) => o.orderStatuses[vendor.id] == OrderStatus.completed)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Orders',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      body: SafeArea(
        child: ordersAsync.when(
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.orange),
                SizedBox(height: 16),
                Text(
                  'Loading orders...',
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
                  'Failed to load orders',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Please check your connection and try again',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(orderProvider.notifier).refresh(),
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
                          'Orders Overview',
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
                      spacing: 8,
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${orders.length}',
                            'Total',
                            Colors.blue,
                            Icons.receipt_long,
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            '${orders.where((order) => order.orderStatuses[vendor.id] == OrderStatus.pending).length}',
                            'New',
                            Colors.orange,
                            Icons.hourglass_empty,
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            '${orders.where((order) => order.orderStatuses[vendor.id] == OrderStatus.ready).length}',
                            'Ready',
                            Colors.green,
                            Icons.check_circle_outline,
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            '${orders.where((order) => order.orderStatuses[vendor.id] == OrderStatus.completed).length}',
                            'Done',
                            Colors.grey,
                            Icons.task_alt,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filter Tabs
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
                    children: [
                      _buildFilterChip('All', null, ref),
                      _buildFilterChip('New Orders', OrderStatus.pending, ref),
                      _buildFilterChip('Ready', OrderStatus.ready, ref),
                      _buildFilterChip('Completed', OrderStatus.completed, ref),
                    ],
                  ),
                ),
              ),

              // Divider
              Container(height: 1, color: Colors.grey[200]),

              // Orders Content
              Expanded(
                child: orders.isEmpty
                    ? _buildEmptyState()
                    : filteredOrders.isEmpty
                    ? _buildNoResultsState(statusFilter)
                    : SingleChildScrollView(
                        child: Column(
                          spacing: 12,
                          children: [
                            SizedBox(height: 12),

                            // Pending Orders
                            if (pendingOrders.isNotEmpty)
                              _buildOrderSection(
                                'New Orders',
                                pendingOrders,
                                Colors.orange,
                                ref,
                                context,
                              ),

                            // Ready Orders
                            if (readyOrders.isNotEmpty)
                              _buildOrderSection(
                                'Ready',
                                readyOrders,
                                Colors.blue,
                                ref,
                                context,
                              ),

                            // Completed Orders
                            if (completedOrders.isNotEmpty)
                              _buildOrderSection(
                                'Completed',
                                completedOrders,
                                Colors.green,
                                ref,
                                context,
                              ),

                            SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey[400]),
          Text(
            'No Orders Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'Orders will appear here when customers place them',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(OrderStatus? filter) {
    String filterName = '';
    switch (filter) {
      case OrderStatus.pending:
        filterName = 'new orders';
        break;
      case OrderStatus.ready:
        filterName = 'ready orders';
        break;
      case OrderStatus.completed:
        filterName = 'completed orders';
        break;
      default:
        filterName = 'orders';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          Icon(Icons.filter_list_off, size: 60, color: Colors.grey[400]),
          Text(
            'No $filterName found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'Try selecting a different filter or check back later',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection(
    String title,
    List<Order> orders,
    Color color,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          ...orders.asMap().entries.map((entry) {
            final index = entry.key;
            final order = entry.value;
            final isLast = index == orders.length - 1;

            return _buildOrderCard(order, ref, isLast, context);
          }),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    Order order,
    WidgetRef ref,
    bool isLast,
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    order.orderNumber,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _formatTime(DateTime.parse(order.createdAt)),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
              // we only show the total for the vendor's menu items
              Text(
                'GHC ${order.items.where((item) => item['vendorId'] == ref.read(currentVendorProvider)?.id).fold<double>(0, (sum, item) => sum + double.parse(item['subtotal']))}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),

          // Customer Info
          Column(
            spacing: 6,
            children: [
              // Customer Name & Delivery Type
              Row(
                spacing: 6,
                children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    order.deliveryOptions == DeliveryOptions.delivery
                        ? Icons.delivery_dining
                        : Icons.store,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  Text(
                    order.deliveryOptions.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Phone Number
              Row(
                spacing: 6,
                children: [
                  Icon(Icons.phone_outlined, size: 14, color: Colors.grey[600]),
                  Expanded(
                    child: Text(
                      order.customerPhone,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),

              // Location
              Row(
                spacing: 6,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  Expanded(
                    child: Text(
                      order.customerLocation,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Email
              Row(
                spacing: 6,
                children: [
                  Icon(Icons.email_outlined, size: 14, color: Colors.grey[600]),
                  Expanded(
                    child: Text(
                      'Email not available',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Order Items
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                // we only show items that are in the vendor's menu
                ...order.items
                    .where(
                      (item) =>
                          item['vendorId'] ==
                          ref.read(currentVendorProvider)?.id,
                    )
                    .map((item) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['quantity']}x ${item['name']}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            'GHC ${item['price']}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      );
                    }),
              ],
            ),
          ),

          // Customer Notes
          if (order.notes.isNotEmpty)
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note_outlined, size: 14, color: Colors.amber[700]),
                  Expanded(
                    child: Text(
                      order.notes,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[800],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Status Action Buttons
          _buildStatusActions(order, ref, context),
        ],
      ),
    );
  }

  Widget _buildStatusActions(Order order, WidgetRef ref, BuildContext context) {
    final vendorId = ref.read(currentVendorProvider)!.id;
    final orderStatus = order.orderStatuses[vendorId] ?? OrderStatus.pending;

    switch (orderStatus) {
      case OrderStatus.pending:
        return _buildActionButton(
          'Mark as Ready',
          AppColors.orange,
          () => _updateOrderStatus(order, OrderStatus.ready, ref, context),
          fullWidth: true,
        );

      case OrderStatus.ready:
        return _buildActionButton(
          'Mark as Completed',
          Colors.green,
          () => _updateOrderStatus(order, OrderStatus.completed, ref, context),
          fullWidth: true,
        );

      case OrderStatus.completed:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 6),
              Text(
                'Order Completed',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildActionButton(
    String text,
    Color color,
    VoidCallback onTap, {
    bool isOutlined = false,
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 32,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : color,
          foregroundColor: isOutlined ? color : Colors.white,
          elevation: 0,
          side: isOutlined ? BorderSide(color: color) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _updateOrderStatus(
    Order order,
    OrderStatus newStatus,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final orderNotifier = ref.read(orderProvider.notifier);
    final vendorId = ref.read(currentVendorProvider)!.id;

    await orderNotifier.updateVendorOrderStatus(
      order.id,
      vendorId,
      newStatus,
      context: context,
    );
  }

  Widget _buildFilterChip(String label, OrderStatus? status, WidgetRef ref) {
    final selectedFilter = ref.watch(orderStatusFilterProvider);
    final isSelected = selectedFilter == status;

    return GestureDetector(
      onTap: () {
        ref.read(orderStatusFilterProvider.notifier).state = status;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.orange : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
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
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            spreadRadius: 0,
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        spacing: 6,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: color),
          ),

          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
