import 'dart:io';
import 'dart:typed_data'; // Add this import
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dine/core/logger.dart';

/// Service for handling Supabase storage operations
class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload vendor image to Supabase storage - FIXED for web compatibility
  Future<String> uploadVendorImage(XFile imageFile, String vendorId) async {
    logger.postgrestLog(
      'Uploading vendor image for vendor: $vendorId',
      trace: 'StorageService.uploadVendorImage',
    );

    String bucketPath = '';

    try {
      String fileName = '';
      if (kIsWeb) {
        final mimeType = imageFile.mimeType;
        final extension = mimeType!.split('/')[1];
        fileName =
            'vendor_${vendorId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
        // Web implementation
        bucketPath = 'vendors/$fileName';
        final bytes = await imageFile
            .readAsBytes(); // XFile.readAsBytes() works on web
        await _supabase.storage
            .from('restaurant')
            .uploadBinary(
              bucketPath,
              bytes,
              fileOptions: FileOptions(contentType: mimeType),
            );
      } else {
        // Mobile/Desktop implementation
        final extension = path.extension(imageFile.path);
        fileName =
            'vendor_${vendorId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
        bucketPath = 'vendors/$fileName';
        final file = File(imageFile.path);
        await _supabase.storage.from('restaurant').upload(bucketPath, file);
      }

      // Get public URL
      final publicUrl = _supabase.storage
          .from('restaurant')
          .getPublicUrl(bucketPath);

      logger.postgrestLog('Successfully uploaded vendor image: $publicUrl');
      return publicUrl;
    } catch (e) {
      logger.postgrestLog(
        'Failed to upload vendor image: $e',
        error: e,
        trace: 'StorageService.uploadVendorImage',
      );
      throw Exception('Failed to upload vendor image: $e');
    }
  }

  /// Upload menu item image to Supabase storage - FIXED for web compatibility
  Future<String> uploadMenuItemImage(XFile imageFile, String menuItemId) async {
    logger.postgrestLog(
      'Uploading menu item image for item: $menuItemId',
      trace: 'StorageService.uploadMenuItemImage',
    );

    String bucketPath = '';

    try {
      String fileName = '';

      if (kIsWeb) {
        final mimeType = imageFile.mimeType;
        final extension = mimeType!.split('/')[1];
        fileName =
            'menu_${menuItemId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
        // Web implementation
        bucketPath = 'menus/$fileName';
        final bytes = await imageFile
            .readAsBytes(); // XFile.readAsBytes() works on web
        await _supabase.storage
            .from('restaurant')
            .uploadBinary(
              bucketPath,
              bytes,
              fileOptions: FileOptions(contentType: mimeType),
            );
      } else {
        // Mobile/Desktop implementation
        final extension = path.extension(imageFile.path);
        fileName =
            'menu_${menuItemId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
        bucketPath = 'menus/$fileName';
        final file = File(imageFile.path);
        await _supabase.storage.from('restaurant').upload(bucketPath, file);
      }

      // Get public URL
      final publicUrl = _supabase.storage
          .from('restaurant')
          .getPublicUrl(bucketPath);

      logger.postgrestLog('Successfully uploaded menu item image: $publicUrl');
      return publicUrl;
    } catch (e) {
      logger.postgrestLog(
        'Failed to upload menu item image: $e',
        error: e,
        trace: 'StorageService.uploadMenuItemImage',
      );
      throw Exception('Failed to upload menu item image: $e');
    }
  }

  /// Delete image from Supabase storage
  Future<void> deleteImage(String imageUrl) async {
    logger.postgrestLog(
      'Deleting image: $imageUrl',
      trace: 'StorageService.deleteImage',
    );

    try {
      // Extract bucket path from public URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length >= 3) {
        final bucketName = pathSegments[pathSegments.length - 3];
        final filePath = pathSegments
            .sublist(pathSegments.length - 2)
            .join('/');

        await _supabase.storage.from(bucketName).remove([filePath]);

        logger.postgrestLog('Successfully deleted image: $imageUrl');
      }
    } catch (e) {
      logger.postgrestLog(
        'Failed to delete image: $e',
        error: e,
        trace: 'StorageService.deleteImage',
      );
      // Don't throw error for delete operations - log and continue
    }
  }

  /// Get optimized image URL with transformations
  String getOptimizedImageUrl(
    String originalUrl, {
    int? width,
    int? height,
    int? quality,
  }) {
    try {
      final uri = Uri.parse(originalUrl);
      final queryParams = <String, String>{};

      if (width != null) queryParams['width'] = width.toString();
      if (height != null) queryParams['height'] = height.toString();
      if (quality != null) queryParams['quality'] = quality.toString();

      if (queryParams.isNotEmpty) {
        return uri.replace(queryParameters: queryParams).toString();
      }

      return originalUrl;
    } catch (e) {
      logger.warning('Failed to optimize image URL: $e');
      return originalUrl;
    }
  }
}
