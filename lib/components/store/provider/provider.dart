// Clean provider file - direct exports only, no extra wrappers!

// Export all async providers directly - no wrappers needed!
export 'package:dine/components/store/provider/async_providers.dart';

// That's it! Use the async providers directly:
// 
// 🔥 Data Providers:
// - menuItemProvider (AsyncNotifier<List<MenuItem>>) - All menu items from Supabase
// - vendorProvider (AsyncNotifier<List<Vendor>>) - All vendors from Supabase  
// - orderProvider (AsyncNotifier<List<Order>>) - All orders from Supabase
// - vendorMenuProvider (AsyncNotifier<List<MenuItem>>) - CRUD operations with image upload
//
// 🎯 Computed Providers:
// - filteredMenuItemsProvider (Provider<List<MenuItem>>) - Filtered by category + search + availability
// - filteredVendorsProvider (Provider<List<Vendor>>) - Filtered by search + open status
//
// 🏪 Local State:
// - cartProvider (StateProvider<List<MenuItem>>) - Shopping cart (local only)
// - searchQueryProvider (StateProvider<String>) - Search text
// - selectedCategoryProvider (StateProvider<Category?>) - Selected category filter
// - currentVendorProvider (StateProvider<Vendor?>) - Current vendor (for vendor app)
//
// 🚀 Action Providers (with Supabase integration):
// - orderCreationProvider (FutureProvider.family) - Create order → Supabase
// - vendorAuthProvider (FutureProvider.family) - Vendor authentication
// - vendorRegistrationProvider (FutureProvider.family) - Register vendor + image upload
//
// 📸 Image Upload Features:
// - Vendor registration: Upload image → Supabase storage → get URL → save to DB
// - Menu item creation: Upload image → Supabase storage → get URL → save to DB
// - Automatic image optimization and management
//
// 🎯 Vendor-Specific Filtering:
// - Orders: Filtered by vendor ID in vendor_ids list
// - Menu Items: Filtered by vendor_id field  
// - Local computation for fast UI updates
