import 'dart:io';
import 'package:dine/components/store/data/models/vendor_models.dart';
import 'package:dine/components/store/provider/provider.dart';
import 'package:dine/core/snackbar.dart';
import 'package:dine/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final selectedImageProvider = StateProvider.autoDispose<XFile?>((ref) {
  return null;
});

final pickedImageProvider = StateProvider<bool>((ref) {
  return false;
});

class VendorRegisterScreen extends ConsumerStatefulWidget {
  const VendorRegisterScreen({super.key});

  @override
  ConsumerState<VendorRegisterScreen> createState() =>
      _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends ConsumerState<VendorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  // File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Restaurant name is required';
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

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 10) {
      return 'Please provide a more detailed description';
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

  String? _validateImage() {
    if (ref.watch(selectedImageProvider) == null &&
        ref.watch(pickedImageProvider)) {
      return 'Please select a restaurant image';
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
        // Store XFile directly, not File
        ref.read(selectedImageProvider.notifier).state = pickedFile;
        ref.read(pickedImageProvider.notifier).state = true;
      }
    } catch (e) {
      if (mounted) {
        customSnackbar(
          'Error selecting image. Please try again.',
          context: context,
          type: SnackType.error,
        );
      }
    }
  }

  void _removeImage() {
    ref.read(selectedImageProvider.notifier).state = null;
    ref.read(pickedImageProvider.notifier).state = false;
  }

  Future<void> _registerVendor() async {
    if (ref.read(selectedImageProvider) == null &&
        !_formKey.currentState!.validate()) {
      ref.read(pickedImageProvider.notifier).state = true;
      return;
    }

    print(ref.read(currentVendorProvider)!.toJson());
    setState(() {
      _isLoading = true;
    });

    try {
      // Process tags - split by comma and trim
      print(ref.read(currentVendorProvider)!.id.toString());
      final tagsList = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Create vendor object
      final vendor = Vendor(
        id: ref.read(currentVendorProvider)!.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        isOpen: true, // Default to open for new vendors
        imageUrl: '', // Will be set after image upload
        tags: tagsList.isEmpty ? ['Restaurant'] : tagsList,
      );

      // Get selected image file

      final imageFile = ref.read(selectedImageProvider);

      // Use vendorRegistrationProvider to register with Supabase
      final registrationAsync = ref.read(
        vendorRegistrationProvider({
          'vendor': vendor,
          'imageFile': imageFile,
          'context': context,
        }).future,
      );

      final registeredVendor = await registrationAsync;

      if (mounted && registeredVendor != null) {
        customSnackbar(
          'Registration successful! Welcome to Dine.',
          context: context,
          type: SnackType.success,
        );

        // Set current vendor
        ref.read(currentVendorProvider.notifier).state = registeredVendor;

        // Navigate to vendor dashboard
        ref.read(selectedImageProvider.notifier).state = null;
        ref.read(pickedImageProvider.notifier).state = false;
        context.pushReplacement('/vendor-dashboard');
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      if (mounted) {
        customSnackbar(
          'Registration failed. Please try again.',
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        // title: Text(
        //   'Complete Your Profile',
        //   style: TextStyle(
        //     color: Colors.black,
        //     fontSize: 18,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        leadingWidth: 55,
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: GestureDetector(
            onTap: () {
              ref.read(selectedImageProvider.notifier).state = null;
              ref.read(pickedImageProvider.notifier).state = false;
              context.pop();
            },
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
                  spacing: 24,
                  children: [
                    // Welcome Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),

                      child: Column(
                        spacing: 12,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.restaurant_rounded,
                              size: 30,
                              color: AppColors.orange,
                            ),
                          ),
                          Text(
                            'Tell us about your restaurant',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Restaurant Details
                    Container(
                      padding: EdgeInsets.all(20),
                      // decoration: BoxDecoration(
                      //   color: Colors.white,
                      //   borderRadius: BorderRadius.circular(16),
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.black.withAlpha(50),
                      //       blurRadius: 10,
                      //       offset: Offset(0, 2),
                      //     ),
                      //   ],
                      // ),
                      child: Column(
                        spacing: 16,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Restaurant Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          // Restaurant Name
                          _buildInputField(
                            controller: _nameController,
                            label: 'Restaurant Name',
                            icon: Icons.store_rounded,
                            validator: _validateName,
                            hintText: 'e.g., Mama\'s Kitchen',
                          ),

                          // Restaurant Image
                          _buildImagePicker(),

                          // Phone Number
                          _buildInputField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: _validatePhone,
                            hintText: '+233 or 0xxxxxxxxx',
                          ),

                          // Description
                          _buildInputField(
                            controller: _descriptionController,
                            label: 'Description',
                            icon: Icons.description_outlined,
                            validator: _validateDescription,
                            maxLines: 3,
                            hintText: 'Describe your restaurant and cuisine...',
                          ),

                          // Location
                          _buildInputField(
                            controller: _locationController,
                            label: 'Location',
                            icon: Icons.location_on_outlined,
                            validator: _validateLocation,
                            maxLines: 2,
                            hintText: 'Street address, area, city',
                          ),

                          // Tags
                          _buildInputField(
                            controller: _tagsController,
                            label: 'Tags (Helps customers find you)',
                            icon: Icons.local_offer_outlined,
                            hintText:
                                'Fast Food, Pizza, Local, etc. (comma separated)',
                          ),
                        ],
                      ),
                    ),

                    // Info Section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        spacing: 8,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green[600],
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'What happens next?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[600],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'After registration, you can start adding your menu items and managing orders right away.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Register Button
            Container(
              padding: EdgeInsets.all(20),
              // decoration: BoxDecoration(
              //   color: Colors.white,
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.black.withAlpha(50),
              //       blurRadius: 20,
              //       offset: Offset(0, -5),
              //     ),
              //   ],
              // ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerVendor,
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
                            'Complete Registration',
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          'Restaurant Image',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
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
                        borderRadius: BorderRadius.circular(10),
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
                              size: 18,
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
                        'Tap to add restaurant image',
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
            fillColor: Colors.grey[50],
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
}
