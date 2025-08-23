import 'dart:io';
import 'dart:typed_data'; // Add this import
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dine/components/store/data/models/menu_item_model.dart';
import 'package:dine/components/store/data/models/vendor_models.dart';
import 'package:dine/components/store/data/models/order_model.dart';
import 'package:dine/core/logger.dart';
import 'package:dine/core/services/storage_service.dart';

/// Simplified data source for menu items - fetch everything, filter locally
class MenuItemDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storageService = StorageService();

  /// Fetch ALL menu items from the database
  Future<List<MenuItem>> getAllMenuItems() async {
    try {
      logger.postgrestLog(
        'Fetching all menu items',
        trace: 'MenuItemDataSource.getAllMenuItems',
      );

      final response = await _supabase.from('menuItem').select('*');

      logger.postgrestLog(
        'Successfully fetched ${(response as List).length} menu items',
      );

      return (response as List).map((json) => MenuItem.fromJson(json)).toList();
    } catch (e) {
      logger.postgrestLog(
        'Failed to fetch menu items',
        error: e,
        trace: 'MenuItemDataSource.getAllMenuItems',
      );
      rethrow;
    }
  }

  /// Create a new menu item with image upload
  Future<MenuItem> createMenuItem(MenuItem menuItem, {XFile? imageFile}) async {
    logger.postgrestLog(
      'Creating menu item: ${menuItem.name}',
      trace: 'MenuItemDataSource.createMenuItem',
    );

    String imageUrl = menuItem.imageUrl;

    // Upload image if provided
    if (imageFile != null) {
      imageUrl = await _storageService.uploadMenuItemImage(
        imageFile,
        menuItem.id,
      );
    }

    // Create menu item with image URL
    final menuItemWithImage = MenuItem(
      id: menuItem.id,
      vendorId: menuItem.vendorId,
      name: menuItem.name,
      description: menuItem.description,
      price: menuItem.price,
      imageUrl: imageUrl,
      tags: menuItem.tags,
      category: menuItem.category,
      isAvailable: menuItem.isAvailable,
    );

    final response = await _supabase
        .from('menuItem')
        .insert(menuItemWithImage.toSupabase())
        .select()
        .single();

    logger.postgrestLog('Successfully created menu item: ${menuItem.name}');
    return MenuItem.fromJson(response);
  }

  /// Update an existing menu item
  Future<MenuItem> updateMenuItem(MenuItem menuItem) async {
    logger.postgrestLog(
      'Updating menu item: ${menuItem.id}',
      trace: 'MenuItemDataSource.updateMenuItem',
    );

    final response = await _supabase
        .from('menuItem')
        .update(menuItem.toSupabase())
        .eq('id', menuItem.id)
        .select()
        .single();

    logger.postgrestLog('Successfully updated menu item: ${menuItem.id}');
    return MenuItem.fromJson(response);
  }

  /// Delete a menu item
  Future<void> deleteMenuItem(String id) async {
    logger.postgrestLog(
      'Deleting menu item: $id',
      trace: 'MenuItemDataSource.deleteMenuItem',
    );

    await _supabase.from('menuItem').delete().eq('id', id);

    logger.postgrestLog('Successfully deleted menu item: $id');
  }
}

/// Simplified data source for vendors - fetch everything, filter locally
class VendorDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storageService = StorageService();

  /// Fetch ALL vendors from the database
  Future<List<Vendor>> getAllVendors() async {
    logger.postgrestLog(
      'Fetching all vendors',
      trace: 'VendorDataSource.getAllVendors',
    );

    final response = await _supabase.from('vendor').select('*');

    logger.postgrestLog(
      'Successfully fetched ${(response as List).length} vendors',
    );

    return (response as List).map((json) => Vendor.fromJson(json)).toList();
  }

  /// Create a new vendor with image upload
  Future<Vendor> createVendor(Vendor vendor, {XFile? imageFile}) async {
    logger.postgrestLog(
      'Creating vendor: ${vendor.name}',
      trace: 'VendorDataSource.createVendor',
    );

    String? imageUrl = vendor.imageUrl;

    // Upload image if provided
    if (imageFile != null) {
      imageUrl = await _storageService.uploadVendorImage(imageFile, vendor.id);
    }

    // Create vendor with image URL
    final vendorWithImage = Vendor(
      id: vendor.id,
      name: vendor.name,
      description: vendor.description,
      location: vendor.location,
      phone: vendor.phone,
      isOpen: vendor.isOpen,
      imageUrl: imageUrl,
      tags: vendor.tags,
      code: vendor.code,
    );

    print(vendorWithImage.toSupabase());

    final response = await _supabase
        .from('vendor')
        .update(vendorWithImage.toSupabase())
        .eq('id', vendor.id)
        .select()
        .single();

    logger.postgrestLog('Successfully created vendor: ${vendor.name}');
    return Vendor.fromJson(response);
  }

  /// Update vendor information
  Future<Vendor> updateVendor(Vendor vendor) async {
    logger.postgrestLog(
      'Updating vendor: ${vendor.id}',
      trace: 'VendorDataSource.updateVendor',
    );

    final response = await _supabase
        .from('vendor')
        .update(vendor.toSupabase())
        .eq('id', vendor.id)
        .select()
        .single();

    logger.postgrestLog('Successfully updated vendor: ${vendor.id}');
    return Vendor.fromJson(response);
  }

  /// Authenticate vendor with code (simple query)
  Future<Vendor?> authenticateVendor(String code) async {
    try {
      logger.authLog(
        'Vendor authentication attempt with code: $code',
        trace: 'VendorDataSource.authenticateVendor',
      );

      final response = await _supabase
          .from('vendor')
          .select('*')
          .eq('code', code)
          .maybeSingle();

      if (response == null) {
        logger.authLog(
          'Vendor authentication failed - no vendor found with code: $code',
        );
        return null;
      }

      logger.authLog('Vendor authentication successful for code: $code');
      return Vendor.fromJson(response);
    } catch (e) {
      logger.authLog(
        'Vendor authentication error',
        error: e,
        trace: 'VendorDataSource.authenticateVendor',
      );
      rethrow;
    }
  }
}

/// Simplified data source for orders - fetch everything, filter locally
class OrderDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new order
  Future<Order> createOrder(Order order) async {
    logger.postgrestLog(
      'Creating order: ${order.orderNumber}',
      trace: 'OrderDataSource.createOrder',
    );

    final response = await _supabase
        .from('orders')
        .insert(order.toSupabase())
        .select()
        .single();

    logger.postgrestLog('Successfully created order: ${order.orderNumber}');
    return Order.fromJson(response);
  }

  /// Fetch ALL orders from the database (sorted by date)
  Future<List<Order>> getAllOrders() async {
    logger.postgrestLog(
      'Fetching all orders',
      trace: 'OrderDataSource.getAllOrders',
    );

    final response = await _supabase
        .from('orders')
        .select('*')
        .order('created_at', ascending: false);

    logger.postgrestLog(
      'Successfully fetched ${(response as List).length} orders',
    );

    return (response as List).map((json) => Order.fromJson(json)).toList();
  }

  /// Update vendor order status
  Future<Order> updateVendorOrderStatus(
    String orderId,
    String vendorId,
    OrderStatus status,
  ) async {
    try {
      logger.postgrestLog(
        'Updating vendor order status: $orderId, vendor: $vendorId, status: $status',
        trace: 'OrderDataSource.updateVendorOrderStatus',
      );

      // Get current order
      final currentOrderResponse = await _supabase
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();

      // Parse current order
      final currentOrder = Order.fromJson(currentOrderResponse);

      // Update the specific vendor's status
      final updatedOrderStatuses = Map<String, OrderStatus>.from(
        currentOrder.orderStatuses,
      );
      updatedOrderStatuses[vendorId] = status;

      // Convert back to JSON format for database
      final statusesJson = <String, String>{};
      updatedOrderStatuses.forEach((key, value) {
        statusesJson[key] = value.name;
      });

      // Update the order in database
      final response = await _supabase
          .from('orders')
          .update({'order_statuses': statusesJson})
          .eq('id', orderId)
          .select()
          .single();

      return Order.fromJson(response);
    } catch (e) {
      logger.postgrestLog(
        'Error updating vendor order status: $e',
        trace: 'OrderDataSource.updateVendorOrderStatus',
      );
      rethrow;
    }
  }

  /// Listen to real-time order updates (all orders)
  Stream<List<Order>> watchAllOrders() {
    logger.postgrestLog(
      'Starting real-time order subscription',
      trace: 'OrderDataSource.watchAllOrders',
    );

    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Order.fromJson(json)).toList());
  }
}
