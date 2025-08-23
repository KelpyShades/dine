# 🍽️ Dine - Multi-Vendor Food Delivery App

A comprehensive Flutter application that connects customers with multiple food vendors for seamless food ordering and delivery management.

## 📱 App Overview

Dine is a sophisticated food delivery platform that supports multiple vendors, real-time order management, and comprehensive analytics. The app consists of two main interfaces:

- **Customer App**: Browse menus, place orders, and track delivery
- **Vendor Dashboard**: Manage orders, menu items, and view business analytics

## ✨ Key Features

### 🛒 Customer Features

- **Multi-Vendor Browsing**: Browse food items from multiple vendors in one app
- **Smart Search**: Search across vendors and menu items with unified results
- **Category Filtering**: Filter by food categories (meals, drinks, desserts, snacks)
- **Shopping Cart**: Add items from different vendors to cart
- **Order Placement**: Simple order form with delivery options
- **Real-time Updates**: Live order status updates

### 🏪 Vendor Features

- **Vendor Authentication**: Secure code-based login system
- **Menu Management**: Add, edit, and manage menu items with images
- **Order Management**: View and update order statuses in real-time
- **Business Analytics**: Comprehensive dashboard with revenue tracking
- **Order Statistics**: Track pending, ready, and completed orders
- **Popular Items**: View top-selling menu items

### 🔄 Real-time Features

- **Live Updates**: Supabase real-time subscriptions for instant updates
- **Order Synchronization**: All clients receive real-time order changes
- **Status Updates**: Instant order status changes across devices

## 🏗️ Architecture

### Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL + Real-time)
- **State Management**: Riverpod with AsyncNotifier
- **Image Storage**: Supabase Storage
- **Authentication**: Custom vendor code system

### Project Structure

```
lib/
├── components/
│   ├── store/           # Customer-facing screens
│   │   ├── views/       # Store, cart, order forms
│   │   ├── data/        # Models, repositories, data sources
│   │   └── provider/    # Riverpod providers
│   └── vendor/          # Vendor dashboard
│       ├── views/       # Analytics, orders, menu management
│       └── data/        # Vendor-specific data handling
├── core/                # Core services and utilities
│   ├── services/        # Storage, real-time, error handling
│   ├── theme/           # App styling and colors
│   └── router/          # Navigation and routing
└── main.dart           # App entry point
```

### Data Layer Architecture

```
UI Layer (Screens)
    ↓
Provider Layer (Riverpod)
    ↓
Repository Layer (Business Logic)
    ↓
DataSource Layer (API Calls)
    ↓
Supabase Backend
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Supabase account and project
- Android Studio / VS Code

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/dine.git
   cd dine
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Supabase**

   - Create a new Supabase project
   - Get your project URL and anon key
   - Update `lib/core/constants.dart` with your credentials

4. **Set up environment variables**

   ```dart
   // lib/core/constants.dart
   class SupabaseConstants {
     static const String url = 'YOUR_SUPABASE_URL';
     static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
   }
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🗄️ Database Schema

### Tables Structure

#### Vendors Table

```sql
vendors (
  id: uuid PRIMARY KEY,
  name: text,
  description: text,
  location: text,
  image_url: text,
  is_open: boolean,
  code: text UNIQUE,
  tags: text[],
  created_at: timestamp
)
```

#### Menu Items Table

```sql
menu_items (
  id: uuid PRIMARY KEY,
  vendor_id: uuid REFERENCES vendors(id),
  name: text,
  description: text,
  price: decimal,
  category: text,
  image_url: text,
  is_available: boolean,
  tags: text[],
  created_at: timestamp
)
```

#### Orders Table

```sql
orders (
  id: uuid PRIMARY KEY,
  order_number: text,
  vendor_ids: uuid[],
  customer_name: text,
  customer_phone: text,
  customer_location: text,
  notes: text,
  items: jsonb,
  order_statuses: jsonb,
  created_at: timestamp,
  total: text,
  delivery_option: text
)
```

## 🔧 Configuration

### Supabase Setup

1. **Enable Real-time**

   ```sql
   -- Enable real-time for all tables
   alter publication supabase_realtime add table vendors;
   alter publication supabase_realtime add table menuItems;
   alter publication supabase_realtime add table orders;
   ```

2. **Row Level Security (RLS)**

   ```sql
   -- Enable RLS
   alter table vendors enable row level security;
   alter table menuItems enable row level security;
   alter table orders enable row level security;
   ```

3. **Storage Policies**
   ```sql
   -- Allow public read access to images
   create policy "Public read access" on storage.objects
   for select using (bucket_id = 'images');
   ```

### Environment Configuration

```dart
// lib/core/constants.dart
class AppConfig {
  static const bool isProduction = false;
  static const String appName = 'Dine';
  static const String appVersion = '1.0.0';
}
```

## 📱 App Flow

### Customer Journey

1. **Browse**: View available vendors and menu items
2. **Search**: Find specific foods or vendors
3. **Filter**: Narrow down by categories
4. **Add to Cart**: Select items from multiple vendors
5. **Checkout**: Fill order form with delivery details
6. **Confirm**: Receive order confirmation and number
7. **Track**: Monitor order status updates

### Vendor Journey

1. **Login**: Authenticate with vendor code
2. **Dashboard**: View order overview and analytics
3. **Orders**: Manage incoming orders and update statuses
4. **Menu**: Add/edit menu items and manage availability
5. **Analytics**: Monitor business performance and revenue

## 🎨 UI Components

### Design System

- **Colors**: Consistent color palette with primary orange theme
- **Typography**: Clear hierarchy with readable fonts
- **Spacing**: Consistent 8px grid system
- **Shadows**: Subtle elevation for depth
- **Gradients**: Modern gradient backgrounds for key sections

### Key Components

- **FeaturedFoodCard**: Hero food item display
- **CategoryCard**: Food category selection
- **ItemCard**: Individual menu item display
- **OrderCard**: Order information display
- **StatCard**: Analytics metric display

## 🔐 Security Features

### Authentication

- **Vendor Codes**: Unique codes for vendor access
- **No Customer Accounts**: Simplified customer experience
- **Secure API**: Supabase RLS policies

### Data Protection

- **Input Validation**: Server-side validation for all inputs
- **SQL Injection Prevention**: Parameterized queries
- **Image Upload Security**: File type and size validation

## 📊 Analytics & Reporting

### Vendor Analytics

- **Revenue Tracking**: Accurate vendor-specific revenue calculation
- **Order Statistics**: Pending, ready, and completed order counts
- **Popular Items**: Top-selling menu items analysis
- **Category Breakdown**: Menu category distribution
- **Recent Performance**: Latest order activity

### Business Insights

- **Total Revenue**: Sum of completed orders (vendor portion only)
- **Average Order Value**: Mean order value for vendor items
- **Order Trends**: Historical order data analysis
- **Menu Performance**: Item popularity and sales metrics

## 🚀 Performance Features

### Optimization

- **Local Filtering**: Client-side filtering for better performance
- **Image Caching**: Efficient image loading and caching
- **Lazy Loading**: Load data as needed
- **Real-time Updates**: Efficient subscription management

### Scalability

- **Provider Architecture**: Scalable state management
- **Repository Pattern**: Clean separation of concerns
- **Async Operations**: Non-blocking UI operations
- **Error Handling**: Graceful error recovery

## 🧪 Testing

### Test Coverage

- **Unit Tests**: Core business logic testing
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end flow testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## 📦 Build & Deployment

### Android Build

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS Build

```bash
# Build iOS app
flutter build ios --release
```

### Web Build

```bash
# Build web version
flutter build web --release
```

## 🔄 State Management

### Riverpod Architecture

- **AsyncNotifier**: For async data operations
- **StateProvider**: For simple state management
- **Provider**: For computed values
- **Family Provider**: For parameterized providers

### Key Providers

```dart
// Data providers
final menuItemProvider = AsyncNotifierProvider<MenuItemNotifier, List<MenuItem>>();
final vendorProvider = AsyncNotifierProvider<VendorNotifier, List<Vendor>>();
final orderProvider = AsyncNotifierProvider<OrderNotifier, List<Order>>();

// Computed providers
final filteredMenuItemsProvider = Provider<List<MenuItem>>();
final vendorOrdersProvider = Provider.family<List<Order>, String>();
final vendorOrderStatsProvider = Provider.family<Map<String, int>, String>();
```

## 🌐 API Integration

### Supabase Services

- **Database**: PostgreSQL with real-time subscriptions
- **Storage**: Image upload and management
- **Auth**: Custom vendor authentication system
- **Real-time**: Live data synchronization

### Data Flow

1. **Fetch**: Initial data loading from Supabase
2. **Subscribe**: Real-time subscription setup
3. **Update**: Local state updates on changes
4. **Sync**: Automatic data synchronization

## 🐛 Troubleshooting

### Common Issues

#### Real-time Not Working

- Check Supabase real-time configuration
- Verify subscription setup in providers
- Ensure proper error handling

#### Image Upload Failures

- Verify Supabase storage bucket configuration
- Check file size and type restrictions
- Ensure proper storage policies

#### Order Status Updates

- Verify vendor ID matching
- Check order status mapping
- Ensure proper state management

### Debug Mode

```dart
// Enable debug logging
if (kDebugMode) {
  print('Debug information');
}
```

## 📈 Future Enhancements

### Planned Features

- **Push Notifications**: Order status updates
- **Payment Integration**: Online payment processing
- **Customer Accounts**: Order history and preferences
- **Driver App**: Delivery tracking and management
- **Advanced Analytics**: Business intelligence dashboard
- **Multi-language Support**: Internationalization

### Technical Improvements

- **Offline Support**: Local data caching
- **Performance Monitoring**: App performance analytics
- **Automated Testing**: CI/CD pipeline
- **Code Generation**: Build-time optimizations

## 🤝 Contributing

### Development Guidelines

1. **Code Style**: Follow Dart/Flutter conventions
2. **Architecture**: Maintain clean architecture principles
3. **Testing**: Write tests for new features
4. **Documentation**: Update docs for API changes

### Pull Request Process

1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Submit pull request
5. Code review and merge

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing framework
- **Supabase**: For the backend infrastructure
- **Riverpod**: For state management solutions
- **Community**: For feedback and contributions

## 📞 Support

For support and questions:

- **Issues**: [GitHub Issues](https://github.com/yourusername/dine/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/dine/discussions)
- **Email**: support@dineapp.com

---

**Built with ❤️ using Flutter and Supabase**
