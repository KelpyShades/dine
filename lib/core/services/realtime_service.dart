import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dine/components/store/data/models/vendor_models.dart';
import 'package:dine/components/store/data/models/menu_item_model.dart';
import 'package:dine/components/store/data/models/order_model.dart';
import 'package:dine/core/logger.dart';

/// Service for managing Supabase real-time subscriptions
class RealtimeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _mainChannel;
  bool _isSubscribed = false;

  /// Callbacks for real-time events
  Function(Vendor vendor)? onVendorInserted;
  Function(Vendor vendor)? onVendorUpdated;
  Function(String vendorId)? onVendorDeleted;

  Function(MenuItem menuItem)? onMenuItemInserted;
  Function(MenuItem menuItem)? onMenuItemUpdated;
  Function(String menuItemId)? onMenuItemDeleted;

  Function(Order order)? onOrderInserted;
  Function(Order order)? onOrderUpdated;
  Function(String orderId)? onOrderDeleted;

  /// Initialize real-time subscriptions for all tables
  Future<void> initialize({
    // Vendor callbacks
    Function(Vendor vendor)? onVendorInserted,
    Function(Vendor vendor)? onVendorUpdated,
    Function(String vendorId)? onVendorDeleted,

    // Menu item callbacks
    Function(MenuItem menuItem)? onMenuItemInserted,
    Function(MenuItem menuItem)? onMenuItemUpdated,
    Function(String menuItemId)? onMenuItemDeleted,

    // Order callbacks
    Function(Order order)? onOrderInserted,
    Function(Order order)? onOrderUpdated,
    Function(String orderId)? onOrderDeleted,
  }) async {
    if (_isSubscribed) {
      logger.postgrestLog('Real-time service already initialized');
      return;
    }

    // Store callbacks
    this.onVendorInserted = onVendorInserted;
    this.onVendorUpdated = onVendorUpdated;
    this.onVendorDeleted = onVendorDeleted;

    this.onMenuItemInserted = onMenuItemInserted;
    this.onMenuItemUpdated = onMenuItemUpdated;
    this.onMenuItemDeleted = onMenuItemDeleted;

    this.onOrderInserted = onOrderInserted;
    this.onOrderUpdated = onOrderUpdated;
    this.onOrderDeleted = onOrderDeleted;

    try {
      logger.postgrestLog('Initializing real-time subscriptions');

      // Create a single channel for all tables
      _mainChannel = _supabase.channel('main-realtime-channel');

      // Subscribe to VENDORS table changes
      _mainChannel!
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'vendor',
            callback: (payload) => _handleVendorInsert(payload),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'vendor',
            callback: (payload) => _handleVendorUpdate(payload),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'vendor',
            callback: (payload) => _handleVendorDelete(payload),
          );

      // Subscribe to MENUITEMS table changes
      _mainChannel!
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'menuItem',
            callback: (payload) => _handleMenuItemInsert(payload),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'menuItem',
            callback: (payload) => _handleMenuItemUpdate(payload),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'menuItem',
            callback: (payload) => _handleMenuItemDelete(payload),
          );

      // Subscribe to ORDERS table changes
      _mainChannel!
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'orders',
            callback: (payload) => _handleOrderInsert(payload),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'orders',
            callback: (payload) => _handleOrderUpdate(payload),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'orders',
            callback: (payload) => _handleOrderDelete(payload),
          );

      // Subscribe to the channel
      _mainChannel!.subscribe();
      _isSubscribed = true;

      logger.postgrestLog('Real-time subscriptions initialized successfully');
    } catch (e) {
      logger.postgrestLog(
        'Failed to initialize real-time subscriptions',
        error: e,
        trace: 'RealtimeService.initialize',
      );
      rethrow;
    }
  }

  /// Handle vendor insert events
  void _handleVendorInsert(PostgresChangePayload payload) {
    try {
      logger.postgrestLog('Vendor inserted: ${payload.newRecord}');
      if (onVendorInserted != null && payload.newRecord.isNotEmpty) {
        final vendor = Vendor.fromJson(payload.newRecord);
        onVendorInserted!(vendor);
      }
    } catch (e) {
      logger.postgrestLog('Error handling vendor insert', error: e);
    }
  }

  /// Handle vendor update events
  void _handleVendorUpdate(PostgresChangePayload payload) {
    try {
      logger.postgrestLog('Vendor updated: ${payload.newRecord}');
      if (onVendorUpdated != null && payload.newRecord.isNotEmpty) {
        final vendor = Vendor.fromJson(payload.newRecord);
        onVendorUpdated!(vendor);
      }
    } catch (e) {
      logger.postgrestLog('Error handling vendor update', error: e);
    }
  }

  /// Handle vendor delete events
  void _handleVendorDelete(PostgresChangePayload payload) {
    try {
      logger.postgrestLog('Vendor deleted: ${payload.oldRecord}');
      if (onVendorDeleted != null && payload.oldRecord.isNotEmpty) {
        final vendorId = payload.oldRecord['id'] as String;
        onVendorDeleted!(vendorId);
      }
    } catch (e) {
      logger.postgrestLog('Error handling vendor delete', error: e);
    }
  }

  /// Handle menu item insert events
  void _handleMenuItemInsert(PostgresChangePayload payload) {
    try {
      logger.postgrestLog('Menu item inserted: ${payload.newRecord}');
      if (onMenuItemInserted != null && payload.newRecord.isNotEmpty) {
        final menuItem = MenuItem.fromJson(payload.newRecord);
        onMenuItemInserted!(menuItem);
      }
    } catch (e) {
      logger.postgrestLog('Error handling menu item insert', error: e);
    }
  }

  /// Handle menu item update events
  void _handleMenuItemUpdate(PostgresChangePayload payload) {
    try {
      logger.postgrestLog('Menu item updated: ${payload.newRecord}');
      if (onMenuItemUpdated != null && payload.newRecord.isNotEmpty) {
        final menuItem = MenuItem.fromJson(payload.newRecord);
        onMenuItemUpdated!(menuItem);
      }
    } catch (e) {
      logger.postgrestLog('Error handling menu item update', error: e);
    }
  }

  /// Handle menu item delete events
  void _handleMenuItemDelete(PostgresChangePayload payload) {
    try {
      logger.postgrestLog('Menu item deleted: ${payload.oldRecord}');
      if (onMenuItemDeleted != null && payload.oldRecord.isNotEmpty) {
        final menuItemId = payload.oldRecord['id'] as String;
        onMenuItemDeleted!(menuItemId);
      }
    } catch (e) {
      logger.postgrestLog('Error handling menu item delete', error: e);
    }
  }

  /// Handle order insert events
  void _handleOrderInsert(PostgresChangePayload payload) {
    try {
      logger.postgrestLog('Order inserted: ${payload.newRecord}');
      if (onOrderInserted != null && payload.newRecord.isNotEmpty) {
        final order = Order.fromJson(payload.newRecord);
        onOrderInserted!(order);
      }
    } catch (e) {
      logger.postgrestLog('Error handling order insert', error: e);
    }
  }

  /// Handle order update events
  void _handleOrderUpdate(PostgresChangePayload payload) {
    try {
      logger.postgrestLog('Order updated: ${payload.newRecord}');
      if (onOrderUpdated != null && payload.newRecord.isNotEmpty) {
        final order = Order.fromJson(payload.newRecord);
        onOrderUpdated!(order);
      }
    } catch (e) {
      logger.postgrestLog('Error handling order update', error: e);
    }
  }

  /// Handle order delete events
  void _handleOrderDelete(PostgresChangePayload payload) {
    try {
      logger.postgrestLog('Order deleted: ${payload.oldRecord}');
      if (onOrderDeleted != null && payload.oldRecord.isNotEmpty) {
        final orderId = payload.oldRecord['id'] as String;
        onOrderDeleted!(orderId);
      }
    } catch (e) {
      logger.postgrestLog('Error handling order delete', error: e);
    }
  }

  /// Dispose and cleanup subscriptions
  Future<void> dispose() async {
    if (_mainChannel != null) {
      try {
        await _mainChannel!.unsubscribe();
        logger.postgrestLog('Real-time subscriptions disposed');
      } catch (e) {
        logger.postgrestLog(
          'Error disposing real-time subscriptions',
          error: e,
        );
      }
    }
    _isSubscribed = false;
    _mainChannel = null;
  }

  /// Check if service is subscribed
  bool get isSubscribed => _isSubscribed;
}

/// Global instance
final realtimeService = RealtimeService();
