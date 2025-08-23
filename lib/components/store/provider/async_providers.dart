import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:dine/components/store/data/datasource.dart';
import 'package:dine/components/store/data/repository.dart';
import 'package:dine/components/store/data/models/menu_item_model.dart';
import 'package:dine/components/store/data/models/vendor_models.dart';
import 'package:dine/components/store/data/models/order_model.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dine/core/services/realtime_service.dart';

/// Data source providers
final menuItemDataSourceProvider = Provider<MenuItemDataSource>((ref) {
  return MenuItemDataSource();
});

final vendorDataSourceProvider = Provider<VendorDataSource>((ref) {
  return VendorDataSource();
});

final orderDataSourceProvider = Provider<OrderDataSource>((ref) {
  return OrderDataSource();
});

/// Repository providers
final menuItemRepositoryProvider = Provider<MenuItemRepository>((ref) {
  return MenuItemRepository(ref.watch(menuItemDataSourceProvider));
});

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepository(ref.watch(vendorDataSourceProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(orderDataSourceProvider));
});

/// Async notifier for menu items - fetch all, filter locally
class MenuItemNotifier extends AsyncNotifier<List<MenuItem>> {
  bool _realtimeInitialized = false;

  @override
  Future<List<MenuItem>> build() async {
    // Initial load of ALL menu items
    final repository = ref.watch(menuItemRepositoryProvider);
    final items = await repository.getAllMenuItems();
    print('items: $items');

    // Initialize real-time subscriptions after initial load
    if (!_realtimeInitialized) {
      _initializeRealtime();
      _realtimeInitialized = true;
    }

    return items ?? [];
  }

  /// Initialize real-time subscriptions for menu items
  void _initializeRealtime() {
    realtimeService.onMenuItemInserted = (menuItem) {
      _handleMenuItemInserted(menuItem);
    };

    realtimeService.onMenuItemUpdated = (menuItem) {
      _handleMenuItemUpdated(menuItem);
    };

    realtimeService.onMenuItemDeleted = (menuItemId) {
      _handleMenuItemDeleted(menuItemId);
    };
  }

  /// Handle real-time menu item insertion
  void _handleMenuItemInserted(MenuItem newMenuItem) {
    state.whenData((currentItems) {
      state = AsyncValue.data([...currentItems, newMenuItem]);
    });
  }

  /// Handle real-time menu item updates
  void _handleMenuItemUpdated(MenuItem updatedMenuItem) {
    state.whenData((currentItems) {
      final updatedItems = currentItems.map((item) {
        return item.id == updatedMenuItem.id ? updatedMenuItem : item;
      }).toList();
      state = AsyncValue.data(updatedItems);
    });
  }

  /// Handle real-time menu item deletion
  void _handleMenuItemDeleted(String deletedItemId) {
    state.whenData((currentItems) {
      final filteredItems = currentItems
          .where((item) => item.id != deletedItemId)
          .toList();
      state = AsyncValue.data(filteredItems);
    });
  }

  /// Refresh menu items
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.watch(menuItemRepositoryProvider);
      final menuItems = await repository.getAllMenuItems();
      state = AsyncValue.data(menuItems ?? []);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Get filtered items by category (computed locally)
  List<MenuItem> getByCategory(Category category) {
    return state.maybeWhen(
      data: (items) =>
          items.where((item) => item.category == category).toList(),
      orElse: () => [],
    );
  }

  /// Get available items only (computed locally)
  List<MenuItem> getAvailableItems() {
    return state.maybeWhen(
      data: (items) => items.where((item) => item.isAvailable).toList(),
      orElse: () => [],
    );
  }

  /// Get items for vendor (computed locally)
  List<MenuItem> getByVendor(String vendorId) {
    return state.maybeWhen(
      data: (items) =>
          items.where((item) => item.vendorId == vendorId).toList(),
      orElse: () => [],
    );
  }
}

/// Async notifier for vendors - fetch all, filter locally
class VendorNotifier extends AsyncNotifier<List<Vendor>> {
  bool _realtimeInitialized = false;

  @override
  Future<List<Vendor>> build() async {
    // Initial load of ALL vendors
    final repository = ref.watch(vendorRepositoryProvider);
    final vendors = await repository.getAllVendors();

    // Initialize real-time subscriptions after initial load
    if (!_realtimeInitialized) {
      _initializeRealtime();
      _realtimeInitialized = true;
    }

    return vendors ?? [];
  }

  /// Initialize real-time subscriptions for vendors
  void _initializeRealtime() {
    realtimeService.onVendorInserted = (vendor) {
      _handleVendorInserted(vendor);
    };

    realtimeService.onVendorUpdated = (vendor) {
      _handleVendorUpdated(vendor);
    };

    realtimeService.onVendorDeleted = (vendorId) {
      _handleVendorDeleted(vendorId);
    };
  }

  /// Handle real-time vendor insertion
  void _handleVendorInserted(Vendor newVendor) {
    state.whenData((currentVendors) {
      state = AsyncValue.data([...currentVendors, newVendor]);
    });
  }

  /// Handle real-time vendor updates
  void _handleVendorUpdated(Vendor updatedVendor) {
    state.whenData((currentVendors) {
      final updatedVendors = currentVendors.map((vendor) {
        return vendor.id == updatedVendor.id ? updatedVendor : vendor;
      }).toList();
      state = AsyncValue.data(updatedVendors);
    });
  }

  /// Handle real-time vendor deletion
  void _handleVendorDeleted(String deletedVendorId) {
    state.whenData((currentVendors) {
      final filteredVendors = currentVendors
          .where((vendor) => vendor.id != deletedVendorId)
          .toList();
      state = AsyncValue.data(filteredVendors);
    });
  }

  /// Refresh vendors
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.watch(vendorRepositoryProvider);
      final vendors = await repository.getAllVendors();
      state = AsyncValue.data(vendors ?? []);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Get open vendors only (computed locally)
  List<Vendor> getOpenVendors() {
    return state.maybeWhen(
      data: (vendors) => vendors.where((vendor) => vendor.isOpen).toList(),
      orElse: () => [],
    );
  }

  /// Get vendor by ID (computed locally)
  Vendor? getById(String id) {
    return state.maybeWhen(
      data: (vendors) => vendors.where((vendor) => vendor.id == id).firstOrNull,
      orElse: () => null,
    );
  }
}

/// Async notifier for vendor menu items (CRUD operations)
class VendorMenuNotifier extends AsyncNotifier<List<MenuItem>> {
  @override
  Future<List<MenuItem>> build() async {
    // Start with all menu items from main provider
    final menuNotifier = ref.watch(menuItemProvider.notifier);
    await menuNotifier.refresh();
    return ref.watch(menuItemProvider).value ?? [];
  }

  /// Add new menu item with image
  Future<void> addMenuItem(
    MenuItem menuItem, {
    XFile? imageFile,
    BuildContext? context,
  }) async {
    final repository = ref.watch(menuItemRepositoryProvider);
    final newItem = await repository.createMenuItem(
      menuItem,
      imageFile: imageFile,
      context: context,
    );

    if (newItem != null) {
      // Refresh main menu items to include new item
      ref.read(menuItemProvider.notifier).refresh();
    }
  }

  /// Update menu item
  Future<void> updateMenuItem(
    MenuItem menuItem, {
    BuildContext? context,
  }) async {
    final repository = ref.watch(menuItemRepositoryProvider);
    final updatedItem = await repository.updateMenuItem(
      menuItem,
      context: context,
    );

    if (updatedItem != null) {
      // Refresh main menu items to reflect changes
      ref.read(menuItemProvider.notifier).refresh();
    }
  }

  /// Delete menu item
  Future<void> deleteMenuItem(String id, {BuildContext? context}) async {
    final repository = ref.watch(menuItemRepositoryProvider);
    await repository.deleteMenuItem(id, context: context);

    // Refresh main menu items to remove deleted item
    ref.read(menuItemProvider.notifier).refresh();
  }

  /// Get items for specific vendor (computed locally)
  List<MenuItem> getVendorItems(String vendorId) {
    return ref.read(menuItemProvider.notifier).getByVendor(vendorId);
  }

  /// Get menu statistics for vendor
  Map<String, int> getVendorMenuStats(String vendorId) {
    final vendorItems = getVendorItems(vendorId);

    return {
      'total': vendorItems.length,
      'available': vendorItems.where((item) => item.isAvailable).length,
      'unavailable': vendorItems.where((item) => !item.isAvailable).length,
    };
  }
}

/// Async notifier for orders - fetch all, filter locally
class OrderNotifier extends AsyncNotifier<List<Order>> {
  bool _realtimeInitialized = false;

  @override
  Future<List<Order>> build() async {
    // Initial load of ALL orders
    final repository = ref.watch(orderRepositoryProvider);
    final orders = await repository.getAllOrders();

    // Initialize real-time subscriptions after initial load
    if (!_realtimeInitialized) {
      _initializeRealtime();
      _realtimeInitialized = true;
    }

    return orders ?? [];
  }

  /// Initialize real-time subscriptions for orders
  void _initializeRealtime() {
    realtimeService.onOrderInserted = (order) {
      _handleOrderInserted(order);
    };

    realtimeService.onOrderUpdated = (order) {
      _handleOrderUpdated(order);
    };

    realtimeService.onOrderDeleted = (orderId) {
      _handleOrderDeleted(orderId);
    };
  }

  /// Handle real-time order insertion
  void _handleOrderInserted(Order newOrder) {
    state.whenData((currentOrders) {
      // Insert new order at the beginning (most recent first)
      state = AsyncValue.data([newOrder, ...currentOrders]);
    });
  }

  /// Handle real-time order updates
  void _handleOrderUpdated(Order updatedOrder) {
    state.whenData((currentOrders) {
      final updatedOrders = currentOrders.map((order) {
        return order.id == updatedOrder.id ? updatedOrder : order;
      }).toList();
      state = AsyncValue.data(updatedOrders);
    });
  }

  /// Handle real-time order deletion
  void _handleOrderDeleted(String deletedOrderId) {
    state.whenData((currentOrders) {
      final filteredOrders = currentOrders
          .where((order) => order.id != deletedOrderId)
          .toList();
      state = AsyncValue.data(filteredOrders);
    });
  }

  /// Refresh orders
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.watch(orderRepositoryProvider);
      final orders = await repository.getAllOrders();
      state = AsyncValue.data(orders ?? []);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update vendor order status
  Future<void> updateVendorOrderStatus(
    String orderId,
    String vendorId,
    OrderStatus status, {
    BuildContext? context,
  }) async {
    final repository = ref.watch(orderRepositoryProvider);
    final updatedOrder = await repository.updateVendorOrderStatus(
      orderId,
      vendorId,
      status,
      context: context,
    );

    if (updatedOrder != null) {
      // Refresh all orders to reflect changes
      await refresh();
    }
  }

  /// Get orders for vendor (computed locally)
  List<Order> getVendorOrders(String vendorId) {
    return state.maybeWhen(
      data: (orders) =>
          orders.where((order) => order.vendorIds.contains(vendorId)).toList(),
      orElse: () => [],
    );
  }

  /// Get orders by status for vendor (computed locally)
  List<Order> getVendorOrdersByStatus(String vendorId, OrderStatus status) {
    return state.maybeWhen(
      data: (orders) => orders
          .where(
            (order) =>
                order.vendorIds.contains(vendorId) &&
                order.orderStatuses[vendorId] == status,
          )
          .toList(),
      orElse: () => [],
    );
  }

  /// Get order statistics for vendor (computed locally)
  Map<String, int> getVendorOrderStats(String vendorId) {
    final vendorOrders = getVendorOrders(vendorId);

    return {
      'total': vendorOrders.length,
      'new': vendorOrders
          .where((o) => o.orderStatuses[vendorId] == OrderStatus.pending)
          .length,
      'ready': vendorOrders
          .where((o) => o.orderStatuses[vendorId] == OrderStatus.ready)
          .length,
      'completed': vendorOrders
          .where((o) => o.orderStatuses[vendorId] == OrderStatus.completed)
          .length,
    };
  }
}

/// Provider instances
final menuItemProvider =
    AsyncNotifierProvider<MenuItemNotifier, List<MenuItem>>(() {
      return MenuItemNotifier();
    });

final vendorProvider = AsyncNotifierProvider<VendorNotifier, List<Vendor>>(() {
  return VendorNotifier();
});

final vendorMenuProvider =
    AsyncNotifierProvider<VendorMenuNotifier, List<MenuItem>>(() {
      return VendorMenuNotifier();
    });

final orderProvider = AsyncNotifierProvider<OrderNotifier, List<Order>>(() {
  return OrderNotifier();
});

/// Cart provider (local state - no backend needed)
final cartProvider = StateProvider<List<MenuItem>>((ref) {
  return [];
});

/// Selected category provider
final selectedCategoryProvider = StateProvider<Category?>((ref) {
  return Category.all;
});

/// Search query provider
final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Current vendor provider (for vendor app)
final currentVendorProvider = StateProvider<Vendor?>((ref) {
  return null;
});

/// Order creation provider
final orderCreationProvider =
    FutureProvider.family<Order?, Map<String, dynamic>>((ref, params) async {
      final repository = ref.watch(orderRepositoryProvider);
      final order = params['order'] as Order;
      final context = params['context'] as BuildContext?;

      final createdOrder = await repository.createOrder(
        order,
        context: context,
      );

      // Refresh orders if successful
      if (createdOrder != null) {
        ref.read(orderProvider.notifier).refresh();
      }

      return createdOrder;
    });

/// Filtered menu items provider (computed locally from all data)
final filteredMenuItemsProvider = Provider<List<MenuItem>>((ref) {
  final menuItemsAsync = ref.watch(menuItemProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return menuItemsAsync.maybeWhen(
    data: (menuItems) {
      var filtered = menuItems
          .where((item) => item.isAvailable)
          .toList(); // Only show available

      // If there's a search query, search across ALL categories
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((item) {
          return item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              item.description.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              item.tags.any(
                (tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()),
              );
        }).toList();

        // Debug: Print search results
      }
      // If no search query, apply category filtering
      else if (selectedCategory != null && selectedCategory != Category.all) {
        filtered = filtered
            .where((item) => item.category == selectedCategory)
            .toList();
      }

      return filtered;
    },
    orElse: () => [],
  );
});

/// Filtered vendors provider (computed locally)
final filteredVendorsProvider = Provider<List<Vendor>>((ref) {
  final vendorsAsync = ref.watch(vendorProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return vendorsAsync.maybeWhen(
    data: (vendors) {
      var filtered = vendors
          .where((vendor) => vendor.isOpen)
          .toList(); // Only show open vendors

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((vendor) {
          final searchLower = searchQuery.toLowerCase();
          return (vendor.name?.toLowerCase().contains(searchLower) ?? false) ||
              (vendor.description?.toLowerCase().contains(searchLower) ??
                  false) ||
              (vendor.location?.toLowerCase().contains(searchLower) ?? false) ||
              vendor.tags.any((tag) => tag.toLowerCase().contains(searchLower));
        }).toList();
      }

      return filtered;
    },
    orElse: () => [],
  );
});

/// Vendor authentication provider
final vendorAuthProvider = FutureProvider.family<Vendor?, Map<String, dynamic>>(
  (ref, params) async {
    final repository = ref.watch(vendorRepositoryProvider);
    final code = params['code'] as String;
    final context = params['context'] as BuildContext?;
    final vendor = await repository.authenticateVendor(code, context: context);
    print(vendor?.toJson());
    return vendor;
  },
);

/// Vendor registration provider
final vendorRegistrationProvider =
    FutureProvider.family<Vendor?, Map<String, dynamic>>((ref, params) async {
      final repository = ref.watch(vendorRepositoryProvider);
      final vendor = params['vendor'] as Vendor;
      final imageFile = params['imageFile'] as XFile?;
      final context = params['context'] as BuildContext?;

      final registeredVendor = await repository.registerVendor(
        vendor,
        imageFile: imageFile,
        context: context,
      );

      // Refresh vendors if successful
      if (registeredVendor != null) {
        ref.read(vendorProvider.notifier).refresh();
      }

      return registeredVendor;
    });

// Vendor-specific providers for vendor dashboard
final vendorOrdersProvider = Provider.family<List<Order>, String>((
  ref,
  vendorId,
) {
  final ordersAsync = ref.watch(orderProvider);

  return ordersAsync.maybeWhen(
    data: (orders) {
      return orders
          .where((order) => order.vendorIds.contains(vendorId))
          .toList();
    },
    orElse: () => [],
  );
});

final vendorMenuItemsProvider = Provider.family<List<MenuItem>, String>((
  ref,
  vendorId,
) {
  final menuItemsAsync = ref.watch(menuItemProvider);

  return menuItemsAsync.maybeWhen(
    data: (menuItems) {
      return menuItems.where((item) => item.vendorId == vendorId).toList();
    },
    orElse: () => [],
  );
});

final vendorOrdersByStatusProvider =
    Provider.family<List<Order>, ({String vendorId, OrderStatus status})>((
      ref,
      params,
    ) {
      final vendorOrders = ref.watch(vendorOrdersProvider(params.vendorId));

      return vendorOrders
          .where(
            (order) => order.orderStatuses[params.vendorId] == params.status,
          )
          .toList();
    });

final vendorOrderStatsProvider = Provider.family<Map<String, int>, String>((
  ref,
  vendorId,
) {
  final vendorOrders = ref.watch(vendorOrdersProvider(vendorId));

  return {
    'total': vendorOrders.length,
    'pending': vendorOrders
        .where((o) => o.orderStatuses[vendorId] == OrderStatus.pending)
        .length,
    'ready': vendorOrders
        .where((o) => o.orderStatuses[vendorId] == OrderStatus.ready)
        .length,
    'completed': vendorOrders
        .where((o) => o.orderStatuses[vendorId] == OrderStatus.completed)
        .length,
  };
});

final vendorMenuStatsProvider = Provider.family<Map<String, int>, String>((
  ref,
  vendorId,
) {
  final vendorMenu = ref.watch(vendorMenuItemsProvider(vendorId));

  return {
    'total': vendorMenu.length,
    'available': vendorMenu.where((item) => item.isAvailable).length,
    'unavailable': vendorMenu.where((item) => !item.isAvailable).length,
  };
});

/// Enhanced unified search provider that combines vendors and menu items
final unifiedSearchResultsProvider = Provider<Map<String, dynamic>>((ref) {
  final searchQuery = ref.watch(searchQueryProvider);
  final filteredVendors = ref.watch(filteredVendorsProvider);
  final filteredMenuItems = ref.watch(filteredMenuItemsProvider);

  return {
    'query': searchQuery,
    'vendors': filteredVendors,
    'menuItems': filteredMenuItems,
    'totalResults': filteredVendors.length + filteredMenuItems.length,
    'hasResults': filteredVendors.isNotEmpty || filteredMenuItems.isNotEmpty,
  };
});
