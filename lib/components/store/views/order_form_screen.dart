import 'package:dine/components/store/data/models/menu_item_model.dart';
import 'package:dine/components/store/data/models/order_model.dart';
import 'package:dine/components/store/provider/provider.dart';
import 'package:dine/core/snackbar.dart';
import 'package:dine/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key});

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  DeliveryOptions _selectedDelivery = DeliveryOptions.delivery;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Ghana phone number format: +233xxxxxxxxx or 0xxxxxxxxx
    final phoneRegex = RegExp(r'^(\+233|0)[0-9]{9}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Enter a valid Ghana phone number';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }
    if (value.trim().length < 5) {
      return 'Please provide a more detailed location';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String _generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'DIN-${timestamp.toString().substring(8)}';
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cartItems = ref.read(cartProvider);

      // Calculate total
      double totalPrice = 0.0;
      for (final item in cartItems) {
        totalPrice += double.parse(item.price);
      }

      // Convert cart items to order format
      final Map<String, int> itemCounts = {};
      final Map<String, MenuItem> uniqueItems = {};

      for (final item in cartItems) {
        itemCounts[item.id] = (itemCounts[item.id] ?? 0) + 1;
        uniqueItems[item.id] = item;
      }

      final orderItems = uniqueItems.entries.map((entry) {
        final item = entry.value;
        final quantity = itemCounts[entry.key]!;
        return {
          'id': item.id,
          'vendorId': item.vendorId,
          'name': item.name,
          'price': item.price,
          'quantity': quantity,
          'subtotal': (double.parse(item.price) * quantity).toStringAsFixed(2),
        };
      }).toList();

      // Create order
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        orderNumber: _generateOrderNumber(),
        vendorIds: cartItems.map((item) => item.vendorId).toSet().toList(),
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        customerLocation: _locationController.text.trim(),
        notes: _notesController.text.trim(),
        items: orderItems,
        orderStatuses: Map.fromEntries(
          // New field: each vendor starts with pending status
          cartItems
              .map((item) => item.vendorId)
              .toSet()
              .map((vendorId) => MapEntry(vendorId, OrderStatus.pending)),
        ),
        createdAt: DateTime.now().toIso8601String(),
        total: totalPrice.toStringAsFixed(2),
        deliveryOptions: _selectedDelivery,
      );

      // Use orderCreationProvider to save order to Supabase
      final orderCreationAsync = ref.read(
        orderCreationProvider({'order': order, 'context': context}).future,
      );

      final createdOrder = await orderCreationAsync;

      if (createdOrder != null) {
        // Clear cart after successful order creation
        ref.read(cartProvider.notifier).state = [];

        // Navigate to confirmation with the created order
        if (mounted) {
          context.pushReplacement('/order-confirmation', extra: createdOrder);
        }
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      if (mounted) {
        customSnackbar(
          'Failed to place order. Please try again.',
          context: context,
          type: SnackType.error,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    double totalPrice = 0.0;
    for (final item in cartItems) {
      totalPrice += double.parse(item.price);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Order Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        spacing: 6,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${cartItems.length} items • GHC ${totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Customer Details Section
                    Column(
                      spacing: 14,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        // Name Field
                        _buildInputField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          validator: _validateName,
                        ),

                        // Phone Field
                        _buildInputField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                          hintText: '+233 or 0xxxxxxxxx',
                        ),

                        // Email Field
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email Address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),

                        // Location Field
                        _buildInputField(
                          controller: _locationController,
                          label: 'Delivery Location',
                          icon: Icons.location_on_outlined,
                          validator: _validateLocation,
                          maxLines: 2,
                          hintText: 'House number, street, area, landmark',
                        ),
                      ],
                    ),

                    // Delivery Options
                    Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Option',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        Row(
                          spacing: 12,
                          children: [
                            Expanded(
                              child: _buildDeliveryOption(
                                DeliveryOptions.delivery,
                                'Delivery',
                                Icons.delivery_dining,
                              ),
                            ),
                            Expanded(
                              child: _buildDeliveryOption(
                                DeliveryOptions.pickup,
                                'Pickup',
                                Icons.store,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Notes Field
                    _buildInputField(
                      controller: _notesController,
                      label: 'Special Notes (Optional)',
                      icon: Icons.note_outlined,
                      maxLines: 3,
                      hintText: 'Any special requests or instructions...',
                    ),

                    SizedBox(height: 60), // Space for bottom button
                  ],
                ),
              ),
            ),

            // Place Order Button
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Place Order • GHC ${totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.orange, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryOption(
    DeliveryOptions option,
    String title,
    IconData icon,
  ) {
    final isSelected = _selectedDelivery == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDelivery = option;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange.withAlpha(50) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.orange : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          spacing: 6,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.orange : Colors.grey[600],
              size: 24,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.orange : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
