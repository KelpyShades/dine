import 'package:flutter_riverpod/legacy.dart';

// Vendor authentication state
final vendorAuthProvider = StateProvider<bool>((ref) {
  return false; // Not authenticated by default
});

// Current vendor code
final vendorCodeProvider = StateProvider<String>((ref) {
  return 'newwsss';
});

// Current vendor session/user data can be added here later
