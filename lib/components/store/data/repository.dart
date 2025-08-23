import 'dart:io';
import 'package:dine/components/store/data/datasource.dart';
import 'package:dine/components/store/data/models/menu_item_model.dart';
import 'package:dine/components/store/data/models/vendor_models.dart';
import 'package:dine/components/store/data/models/order_model.dart';
import 'package:dine/core/error_handling/error_handler.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

/// Repository for menu item operations
/// Handles business logic and coordinates between UI and data source
class MenuItemRepository {
  final MenuItemDataSource _dataSource;

  MenuItemRepository(this._dataSource);

  /// Get all menu items - filtering done locally
  Future<List<MenuItem>?> getAllMenuItems({BuildContext? context}) async {
    return await asyncErrorWrapper<List<MenuItem>>(
      () async => await _dataSource.getAllMenuItems(),
      context: context,
      errorMessage: 'Unable to load menu items. Please check your connection.',
      debugTrace: 'MenuItemRepository.getAllMenuItems',
    );
  }

  /// Create new menu item (vendor functionality)
  Future<MenuItem?> createMenuItem(
    MenuItem menuItem, {
    XFile? imageFile,
    BuildContext? context,
  }) async {
    // Business logic validation
    if (menuItem.name.isEmpty || menuItem.price.isEmpty) {
      throw Exception('Name and price are required.');
    }

    final price = double.tryParse(menuItem.price);
    if (price == null || price <= 0) {
      throw Exception('Please enter a valid price.');
    }

    return await asyncErrorWrapper<MenuItem>(
      () async =>
          await _dataSource.createMenuItem(menuItem, imageFile: imageFile),
      context: context,
      successMessage: '${menuItem.name} added successfully!',
      errorMessage: 'Failed to add menu item. Please try again.',
      debugTrace: 'MenuItemRepository.createMenuItem',
    );
  }

  /// Update existing menu item
  Future<MenuItem?> updateMenuItem(
    MenuItem menuItem, {
    BuildContext? context,
  }) async {
    return await asyncErrorWrapper<MenuItem>(
      () async => await _dataSource.updateMenuItem(menuItem),
      context: context,
      successMessage: 'Menu item updated successfully!',
      errorMessage: 'Failed to update menu item. Please try again.',
      debugTrace: 'MenuItemRepository.updateMenuItem',
    );
  }

  /// Delete menu item
  Future<void> deleteMenuItem(String id, {BuildContext? context}) async {
    await asyncErrorWrapper<void>(
      () async => await _dataSource.deleteMenuItem(id),
      context: context,
      successMessage: 'Menu item deleted successfully!',
      errorMessage: 'Failed to delete menu item. Please try again.',
      debugTrace: 'MenuItemRepository.deleteMenuItem',
    );
  }
}

/// Repository for vendor operations
class VendorRepository {
  final VendorDataSource _dataSource;

  VendorRepository(this._dataSource);

  /// Get all vendors - filtering done locally
  Future<List<Vendor>?> getAllVendors({BuildContext? context}) async {
    return await asyncErrorWrapper<List<Vendor>>(
      () async => await _dataSource.getAllVendors(),
      context: context,
      errorMessage: 'Unable to load restaurants. Please check your connection.',
      debugTrace: 'VendorRepository.getAllVendors',
    );
  }

  /// Register new vendor
  Future<Vendor?> registerVendor(
    Vendor vendor, {
    XFile? imageFile, // Change from File? to XFile?
    BuildContext? context,
  }) async {
    // Business logic validation
    if (vendor.name!.isEmpty ||
        vendor.phone!.isEmpty ||
        vendor.location!.isEmpty) {
      throw Exception('Name, phone, and location are required.');
    }

    final phoneRegex = RegExp(r'^(\+233|0)[0-9]{9}$');
    if (!phoneRegex.hasMatch(vendor.phone!.replaceAll(' ', ''))) {
      throw Exception('Please enter a valid Ghana phone number.');
    }

    return await asyncErrorWrapper<Vendor>(
      () async => await _dataSource.createVendor(vendor, imageFile: imageFile),
      context: context,
      successMessage: 'Vendor registered successfully!',
      errorMessage: 'Failed to register vendor. Please try again.',
      debugTrace: 'VendorRepository.registerVendor',
    );
  }

  /// Update vendor information
  Future<Vendor?> updateVendor(Vendor vendor, {BuildContext? context}) async {
    return await asyncErrorWrapper<Vendor>(
      () async => await _dataSource.updateVendor(vendor),
      context: context,
      successMessage: 'Restaurant information updated successfully!',
      errorMessage: 'Failed to update restaurant information.',
      debugTrace: 'VendorRepository.updateVendor',
    );
  }

  /// Authenticate vendor with code
  Future<Vendor?> authenticateVendor(
    String code, {
    BuildContext? context,
  }) async {
    if (code.isEmpty) {
      throw Exception('Vendor code is required.');
    }

    return await asyncErrorWrapper<Vendor?>(
      () async {
        final vendor = await _dataSource.authenticateVendor(code);

        return vendor;
      },
      context: context,
      errorMessage: 'Authentication failed. Please check your credentials.',
      debugTrace: 'VendorRepository.authenticateVendor',
    );
  }
}

/// Repository for order operations
class OrderRepository {
  final OrderDataSource _dataSource;

  OrderRepository(this._dataSource);

  /// Create new order
  Future<Order?> createOrder(Order order, {BuildContext? context}) async {
    // Business logic validation
    if (order.customerName.isEmpty || order.customerPhone.isEmpty) {
      throw Exception('Customer name and phone are required.');
    }

    if (order.items.isEmpty) {
      throw Exception('Order must contain at least one item.');
    }

    final phoneRegex = RegExp(r'^(\+233|0)[0-9]{9}$');
    if (!phoneRegex.hasMatch(order.customerPhone.replaceAll(' ', ''))) {
      throw Exception('Please enter a valid Ghana phone number.');
    }

    return await asyncErrorWrapper<Order>(
      () async => await _dataSource.createOrder(order),
      context: context,
      successMessage: 'Order placed successfully!',
      errorMessage: 'Failed to place order. Please try again.',
      debugTrace: 'OrderRepository.createOrder',
    );
  }

  /// Get all orders - filtering done locally
  Future<List<Order>?> getAllOrders({BuildContext? context}) async {
    return await asyncErrorWrapper<List<Order>>(
      () async => await _dataSource.getAllOrders(),
      context: context,
      errorMessage: 'Unable to load orders. Please check your connection.',
      debugTrace: 'OrderRepository.getAllOrders',
    );
  }

  /// Update vendor order status
  Future<Order?> updateVendorOrderStatus(
    String orderId,
    String vendorId,
    OrderStatus status, {
    BuildContext? context,
  }) async {
    return await asyncErrorWrapper(
      () async =>
          await _dataSource.updateVendorOrderStatus(orderId, vendorId, status),
      context: context,
      debugTrace: 'OrderRepository.updateVendorOrderStatus',
    );
  }

  /// Watch real-time order updates (all orders)
  Stream<List<Order>> watchAllOrders() {
    return _dataSource.watchAllOrders();
  }
}
