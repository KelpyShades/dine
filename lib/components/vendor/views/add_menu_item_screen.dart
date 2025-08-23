import 'dart:io';
import 'package:dine/components/store/data/models/menu_item_model.dart';
import 'package:dine/components/store/data/models/vendor_models.dart';
import 'package:dine/components/store/provider/provider.dart';
import 'package:dine/core/snackbar.dart';
import 'package:dine/core/theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

final selectedImageProvider = StateProvider.autoDispose<XFile?>((ref) {
  return null;
});

final pickedImageProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

class AddMenuItemScreen extends ConsumerStatefulWidget {
  const AddMenuItemScreen({super.key});

  @override
  ConsumerState<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends ConsumerState<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _tagsController = TextEditingController();

  Category _selectedCategory = Category.meal;
  bool _isAvailable = true;
  bool _isLoading = false;

  // Image picking
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter menu item name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter description';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter price';
    }
    final price = double.tryParse(value.trim());
    if (price == null || price <= 0) {
      return 'Please enter a valid price';
    }
    return null;
  }

  String? _validateImage() {
    if (ref.watch(selectedImageProvider) == null &&
        ref.watch(pickedImageProvider)) {
      return 'Please select a menu item image';
    }
    return null;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          ref.read(selectedImageProvider.notifier).state = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        customSnackbar(
          'Error selecting image',
          context: context,
          type: SnackType.error,
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      ref.read(selectedImageProvider.notifier).state = null;
    });
  }

  Future<void> _addMenuItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final imageError = _validateImage();
    if (imageError != null) {
      customSnackbar(imageError, context: context, type: SnackType.error);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Process tags
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Create new menu item
      final newMenuItem = MenuItem(
        id: 'mi_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        vendorId: ref.read(currentVendorProvider)!.id,
        price: _priceController.text.trim(),
        imageUrl: 'placeholder', // Will be replaced with uploaded URL
        tags: tags,
        category: _selectedCategory,
        isAvailable: _isAvailable,
      );

      // Add menu item using vendorMenuNotifier with image upload
      final vendorMenuNotifier = ref.read(vendorMenuProvider.notifier);
      final imageFile = ref.read(selectedImageProvider);

      await vendorMenuNotifier.addMenuItem(
        newMenuItem,
        imageFile: imageFile,
        context: context,
      );

      if (mounted) {
        customSnackbar(
          '${newMenuItem.name} added successfully!',
          context: context,
          type: SnackType.success,
        );
        ref.read(selectedImageProvider.notifier).state = null;
        ref.read(pickedImageProvider.notifier).state = false;
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        customSnackbar(
          'Error adding menu item: $e',
          context: context,
          type: SnackType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Add Menu Item',
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
            onTap: () {
              ref.read(selectedImageProvider.notifier).state = null;
              ref.read(pickedImageProvider.notifier).state = false;
              context.pop();
            },
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Image
                _buildImagePicker(),

                // Item Details
                _buildSectionTitle('Item Details'),

                // Name
                _buildTextFormField(
                  controller: _nameController,
                  label: 'Item Name',
                  hint: 'e.g. Margherita Pizza',
                  icon: Icons.restaurant_menu,
                  validator: _validateName,
                ),

                // Description
                _buildTextFormField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Describe your menu item...',
                  icon: Icons.description_outlined,
                  validator: _validateDescription,
                  maxLines: 3,
                ),

                // Category
                _buildCategorySelector(),

                // Price
                _buildTextFormField(
                  controller: _priceController,
                  label: 'Price (GHC)',
                  hint: '0.00',
                  icon: Icons.attach_money,
                  validator: _validatePrice,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),

                // Tags
                _buildTextFormField(
                  controller: _tagsController,
                  label: 'Tags (optional)',
                  hint: 'Popular, Spicy, Vegetarian (comma separated)',
                  icon: Icons.label_outline,
                ),

                // Availability Toggle
                _buildAvailabilityToggle(),

                SizedBox(height: 8),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addMenuItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Add Menu Item',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
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
            color: Colors.grey[700],
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
            prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.orange),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Category>(
              value: _selectedCategory,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              style: TextStyle(fontSize: 14, color: Colors.black87),
              onChanged: (Category? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
              items:
                  [
                    Category.meal,
                    Category.drink,
                    Category.dessert,
                    Category.snack,
                  ].map<DropdownMenuItem<Category>>((Category value) {
                    return DropdownMenuItem<Category>(
                      value: value,
                      child: Row(
                        spacing: 8,
                        children: [
                          Icon(
                            _getCategoryIcon(value),
                            size: 18,
                            color: AppColors.orange,
                          ),
                          Text(
                            value.name.toUpperCase(),
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
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

  Widget _buildAvailabilityToggle() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.visibility_outlined, size: 18, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  'Availability',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  _isAvailable
                      ? 'Available for customers'
                      : 'Hidden from customers',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
            },
            activeThumbColor: AppColors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          'Menu Item Image',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _validateImage() != null
                    ? Colors.red
                    : Colors.grey[300]!,
              ),
            ),
            child: ref.watch(selectedImageProvider) != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(
                                ref.watch(selectedImageProvider)!.path,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(ref.watch(selectedImageProvider)!.path),
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 40,
                        color: Colors.grey[600],
                      ),
                      Text(
                        'Tap to add menu item image',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'JPG, PNG • Max 10MB',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
          ),
        ),
        if (_validateImage() != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _validateImage()!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
