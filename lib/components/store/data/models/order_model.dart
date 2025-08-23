enum OrderStatus { pending, ready, completed }

enum DeliveryOptions { delivery, pickup }

class Order {
  final String id;
  final String orderNumber;
  final List<String> vendorIds;
  final String customerName;
  final String customerPhone;
  final String customerLocation;
  // final String customerEmail;
  final String notes;
  final List<Map<String, dynamic>> items;
  final Map<String, OrderStatus>
  orderStatuses; // Changed from statuses to orderStatuses
  final String createdAt;
  final String total;
  final DeliveryOptions deliveryOptions;

  Order({
    required this.id,
    required this.orderNumber,
    required this.vendorIds,
    required this.customerName,
    required this.customerPhone,
    required this.customerLocation,
    // required this.customerEmail,
    required this.notes,
    required this.items,
    required this.orderStatuses, // Changed from statuses
    required this.createdAt,
    required this.total,
    required this.deliveryOptions,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // convert vendor_ids to list of strings
    List<String> vendorIds = (json['vendor_ids'] as Iterable<dynamic>)
        .map((e) => e.toString())
        .toList();
    List<Map<String, dynamic>> items = (json['items'] as Iterable<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    // Parse orderStatuses from JSON
    Map<String, OrderStatus> orderStatuses = {};
    if (json['order_statuses'] != null) {
      final statusesMap = json['order_statuses'] as Map<String, dynamic>;
      statusesMap.forEach((vendorId, status) {
        orderStatuses[vendorId] = OrderStatus.values.byName(status.toString());
      });
    }

    return Order(
      id: json['id'],
      orderNumber: json['order_number'],
      vendorIds: vendorIds,
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerLocation: json['customer_location'],
      // customerEmail: json['customer_email'],
      notes: json['notes'] ?? '',
      items: items,
      orderStatuses: orderStatuses, // Changed from statuses
      createdAt: json['created_at'],
      total: json['total'],
      deliveryOptions: DeliveryOptions.values.byName(json['delivery_option']),
    );
  }

  Map<String, dynamic> toJson() {
    // Convert orderStatuses to JSON format
    Map<String, String> statusesJson = {};
    orderStatuses.forEach((vendorId, status) {
      statusesJson[vendorId] = status.name;
    });

    return {
      'id': id,
      'order_number': orderNumber,
      'vendor_ids': vendorIds,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_location': customerLocation,
      // 'customer_email': customerEmail,
      'notes': notes,
      'items': items,
      'order_statuses': statusesJson, // Changed from status
      'created_at': createdAt,
      'total': total,
      'delivery_option': deliveryOptions.name,
    };
  }

  Map<String, dynamic> toSupabase() {
    // Convert orderStatuses to JSON format
    Map<String, String> statusesJson = {};
    orderStatuses.forEach((vendorId, status) {
      statusesJson[vendorId] = status.name;
    });

    return {
      'order_number': orderNumber,
      'vendor_ids': vendorIds,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_location': customerLocation,
      // 'customer_email': customerEmail,
      'notes': notes,
      'items': items,
      'order_statuses': statusesJson, // Changed from status
      'created_at': createdAt,
      'total': total,
      'delivery_option': deliveryOptions.name,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order.fromJson(map);
  }

  Order copyWith({
    String? id,
    String? orderNumber,
    List<String>? vendorIds,
    String? customerName,
    String? customerPhone,
    String? customerLocation,
    // String? customerEmail,
    String? notes,
    List<Map<String, dynamic>>? items,
    Map<String, OrderStatus>? orderStatuses, // Changed from status
    String? createdAt,
    String? total,
    DeliveryOptions? deliveryOptions,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      vendorIds: vendorIds ?? this.vendorIds,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerLocation: customerLocation ?? this.customerLocation,
      // customerEmail: customerEmail ?? this.customerEmail,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      orderStatuses: orderStatuses ?? this.orderStatuses, // Changed from status
      createdAt: createdAt ?? this.createdAt,
      total: total ?? this.total,
      deliveryOptions: deliveryOptions ?? this.deliveryOptions,
    );
  }

  factory Order.empty() {
    return Order(
      id: '',
      orderNumber: '',
      vendorIds: [],
      customerName: '',
      customerPhone: '',
      customerLocation: '',
      // customerEmail: '',
      notes: '',
      items: [],
      orderStatuses: {}, // Changed from status
      createdAt: '',
      total: '',
      deliveryOptions: DeliveryOptions.delivery,
    );
  }

  // Helper method to get status for a specific vendor
  OrderStatus getVendorStatus(String vendorId) {
    return orderStatuses[vendorId] ?? OrderStatus.pending;
  }

  // Helper method to update status for a specific vendor
  Order updateVendorStatus(String vendorId, OrderStatus newStatus) {
    final newStatuses = Map<String, OrderStatus>.from(orderStatuses);
    newStatuses[vendorId] = newStatus;
    return copyWith(orderStatuses: newStatuses);
  }

  // Helper method to check if all vendors have completed their orders
  bool get isAllCompleted {
    return orderStatuses.values.every(
      (status) => status == OrderStatus.completed,
    );
  }

  // Helper method to check if any vendor is ready
  bool get hasAnyReady {
    return orderStatuses.values.any((status) => status == OrderStatus.ready);
  }
}
