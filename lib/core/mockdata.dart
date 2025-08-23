import '../components/store/data/models/vendor_models.dart';
import '../components/store/data/models/menu_item_model.dart';

// Mock data for vendors
final List<Vendor> mockVendors = [
  Vendor(
    id: '1',
    name: 'Pizza Palace',
    description: 'Authentic Italian pizza with fresh ingredients',
    location: 'Downtown Plaza, 123 Main St',
    phone: '+1234567890',
    isOpen: true,
    imageUrl:
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
    tags: ['Italian', 'Pizza', 'Fast Food'],
  ),
  Vendor(
    id: '2',
    name: 'Burger Barn',
    description: 'Juicy burgers and crispy fries',
    location: 'Food Court, 456 Oak Ave',
    phone: '+1234567891',
    isOpen: true,
    imageUrl:
        'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400',
    tags: ['American', 'Burgers', 'Fast Food'],
  ),
  Vendor(
    id: '3',
    name: 'Sushi Zen',
    description: 'Fresh sushi and Japanese cuisine',
    location: 'Japan Town, 789 Cherry Blvd',
    phone: '+1234567892',
    isOpen: false,
    imageUrl:
        'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
    tags: ['Japanese', 'Sushi', 'Healthy'],
  ),
  Vendor(
    id: '4',
    name: 'Sweet Treats',
    description: 'Delicious desserts and pastries',
    location: 'Bakery Street, 321 Sugar Lane',
    phone: '+1234567893',
    isOpen: true,
    imageUrl: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400',
    tags: ['Desserts', 'Bakery', 'Sweet'],
  ),
  Vendor(
    id: '5',
    name: 'Taco Fiesta',
    description: 'Authentic Mexican tacos and burritos',
    location: 'Mexican Quarter, 567 Salsa St',
    phone: '+1234567894',
    isOpen: true,
    imageUrl:
        'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400',
    tags: ['Mexican', 'Tacos', 'Spicy'],
  ),
  Vendor(
    id: '6',
    name: 'Noodle House',
    description: 'Asian noodles and dumplings',
    location: 'Asian District, 890 Rice Road',
    phone: '+1234567895',
    isOpen: true,
    imageUrl:
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
    tags: ['Asian', 'Noodles', 'Dumplings'],
  ),
  Vendor(
    id: '7',
    name: 'Healthy Greens',
    description: 'Fresh salads and healthy bowls',
    location: 'Fitness Center, 432 Veggie Ave',
    phone: '+1234567896',
    isOpen: true,
    imageUrl:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
    tags: ['Healthy', 'Salads', 'Vegan'],
  ),
  Vendor(
    id: '8',
    name: 'Coffee Corner',
    description: 'Premium coffee and pastries',
    location: 'University Campus, 765 Bean St',
    phone: '+1234567897',
    isOpen: false,
    imageUrl:
        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
    tags: ['Coffee', 'Breakfast', 'Pastries'],
  ),
];

// Mock data for menu items
final List<MenuItem> mockMenuItems = [
  // Pizza Palace Items
  MenuItem(
    id: '1',
    name: 'Margherita Pizza',
    description: 'Classic pizza with tomato, mozzarella, and basil',
    vendorId: '1',
    price: '12.99',
    imageUrl:
        'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
    tags: ['Pizza', 'Meals', 'Italian'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '2',
    name: 'Pepperoni Pizza',
    description: 'Pizza with pepperoni and cheese',
    vendorId: '1',
    price: '14.99',
    imageUrl:
        'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400',
    tags: ['Pizza', 'Meals', 'Italian'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '30',
    name: 'Vegetarian Pizza',
    description: 'Fresh vegetables on a thin crust',
    vendorId: '1',
    price: '13.99',
    imageUrl:
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
    tags: ['Pizza', 'Meals', 'Vegetarian'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '31',
    name: 'BBQ Chicken Pizza',
    description: 'Grilled chicken with BBQ sauce and red onions',
    vendorId: '1',
    price: '15.99',
    imageUrl:
        'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
    tags: ['Pizza', 'Meals', 'BBQ'],
    category: Category.meal,
    isAvailable: true,
  ),

  // Burger Barn Items
  MenuItem(
    id: '3',
    name: 'Classic Burger',
    description: 'Beef patty with lettuce, tomato, and cheese',
    vendorId: '2',
    price: '8.99',
    imageUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
    tags: ['Burgers', 'Meals', 'American'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '4',
    name: 'Chicken Burger',
    description: 'Grilled chicken breast with fresh vegetables',
    vendorId: '2',
    price: '9.99',
    imageUrl:
        'https://images.unsplash.com/photo-1606755962773-d324e2d53f03?w=400',
    tags: ['Burgers', 'Meals', 'Healthy'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '5',
    name: 'French Fries',
    description: 'Crispy golden fries',
    vendorId: '2',
    price: '3.99',
    imageUrl:
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
    tags: ['Snacks', 'Sides'],
    category: Category.snack,
    isAvailable: true,
  ),
  MenuItem(
    id: '32',
    name: 'Double Cheeseburger',
    description: 'Two beef patties with extra cheese',
    vendorId: '2',
    price: '11.99',
    imageUrl: 'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=400',
    tags: ['Burgers', 'Meals', 'American'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '33',
    name: 'Onion Rings',
    description: 'Crispy battered onion rings',
    vendorId: '2',
    price: '4.99',
    imageUrl:
        'https://images.unsplash.com/photo-1639024471283-03518883512d?w=400',
    tags: ['Snacks', 'Sides'],
    category: Category.snack,
    isAvailable: true,
  ),

  // Sushi Zen Items
  MenuItem(
    id: '6',
    name: 'Salmon Roll',
    description: 'Fresh salmon with avocado and cucumber',
    vendorId: '3',
    price: '11.99',
    imageUrl:
        'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
    tags: ['Sushi', 'Meals', 'Healthy'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '7',
    name: 'California Roll',
    description: 'Crab, avocado, and cucumber roll',
    vendorId: '3',
    price: '9.99',
    imageUrl: 'https://images.unsplash.com/photo-1563612198-e1a0ccf96c9a?w=400',
    tags: ['Sushi', 'Meals', 'Healthy'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '34',
    name: 'Sashimi Platter',
    description: 'Assorted fresh raw fish slices',
    vendorId: '3',
    price: '18.99',
    imageUrl: 'https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400',
    tags: ['Sushi', 'Meals', 'Japanese'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '35',
    name: 'Tempura Udon',
    description: 'Thick noodle soup with tempura shrimp',
    vendorId: '3',
    price: '14.99',
    imageUrl:
        'https://images.unsplash.com/photo-1618841557871-b4664fbf0cb3?w=400',
    tags: ['Noodles', 'Meals', 'Japanese'],
    category: Category.meal,
    isAvailable: true,
  ),

  // Sweet Treats Items
  MenuItem(
    id: '8',
    name: 'Chocolate Cake',
    description: 'Rich chocolate cake with frosting',
    vendorId: '4',
    price: '5.99',
    imageUrl:
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400',
    tags: ['Desserts', 'Sweet', 'Cake'],
    category: Category.dessert,
    isAvailable: true,
  ),
  MenuItem(
    id: '9',
    name: 'Strawberry Cheesecake',
    description: 'Creamy cheesecake with fresh strawberries',
    vendorId: '4',
    price: '6.99',
    imageUrl:
        'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400',
    tags: ['Desserts', 'Sweet', 'Cake'],
    category: Category.dessert,
    isAvailable: true,
  ),
  MenuItem(
    id: '10',
    name: 'Ice Cream Sundae',
    description: 'Vanilla ice cream with chocolate sauce',
    vendorId: '4',
    price: '4.99',
    imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400',
    tags: ['Desserts', 'Sweet', 'Cold'],
    category: Category.dessert,
    isAvailable: true,
  ),
  MenuItem(
    id: '36',
    name: 'Tiramisu',
    description: 'Italian coffee-flavored dessert',
    vendorId: '4',
    price: '7.99',
    imageUrl:
        'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400',
    tags: ['Desserts', 'Sweet', 'Italian'],
    category: Category.dessert,
    isAvailable: true,
  ),
  MenuItem(
    id: '37',
    name: 'Fruit Tart',
    description: 'Buttery crust with fresh seasonal fruits',
    vendorId: '4',
    price: '6.49',
    imageUrl:
        'https://images.unsplash.com/photo-1519915028121-7d3463d5b1ff?w=400',
    tags: ['Desserts', 'Sweet', 'Fruit'],
    category: Category.dessert,
    isAvailable: true,
  ),

  // Taco Fiesta Items
  MenuItem(
    id: '38',
    name: 'Beef Tacos',
    description: 'Three soft corn tortillas with seasoned beef',
    vendorId: '5',
    price: '8.99',
    imageUrl:
        'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400',
    tags: ['Mexican', 'Tacos', 'Meals'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '39',
    name: 'Chicken Quesadilla',
    description: 'Grilled flour tortilla with chicken and cheese',
    vendorId: '5',
    price: '9.99',
    imageUrl:
        'https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?w=400',
    tags: ['Mexican', 'Meals', 'Cheese'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '40',
    name: 'Guacamole & Chips',
    description: 'Fresh avocado dip with tortilla chips',
    vendorId: '5',
    price: '5.99',
    imageUrl:
        'https://images.unsplash.com/photo-1600335895229-6e75511892c8?w=400',
    tags: ['Mexican', 'Snacks', 'Vegetarian'],
    category: Category.snack,
    isAvailable: true,
  ),

  // Noodle House Items
  MenuItem(
    id: '41',
    name: 'Pad Thai',
    description: 'Thai stir-fried rice noodles with egg and tofu',
    vendorId: '6',
    price: '11.99',
    imageUrl: 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400',
    tags: ['Asian', 'Noodles', 'Thai'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '42',
    name: 'Pork Dumplings',
    description: 'Steamed dumplings filled with seasoned pork',
    vendorId: '6',
    price: '7.99',
    imageUrl: 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400',
    tags: ['Asian', 'Dumplings', 'Appetizers'],
    category: Category.snack,
    isAvailable: true,
  ),
  MenuItem(
    id: '43',
    name: 'Beef Pho',
    description: 'Vietnamese noodle soup with beef and herbs',
    vendorId: '6',
    price: '12.99',
    imageUrl:
        'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400',
    tags: ['Asian', 'Noodles', 'Soup'],
    category: Category.meal,
    isAvailable: true,
  ),

  // Healthy Greens Items
  MenuItem(
    id: '44',
    name: 'Caesar Salad',
    description: 'Romaine lettuce with Caesar dressing and croutons',
    vendorId: '7',
    price: '8.99',
    imageUrl: 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=400',
    tags: ['Healthy', 'Salads', 'Meals'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '45',
    name: 'Quinoa Bowl',
    description: 'Quinoa with roasted vegetables and tahini dressing',
    vendorId: '7',
    price: '10.99',
    imageUrl:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
    tags: ['Healthy', 'Vegan', 'Meals'],
    category: Category.meal,
    isAvailable: true,
  ),
  MenuItem(
    id: '46',
    name: 'Green Smoothie',
    description: 'Spinach, banana, and almond milk smoothie',
    vendorId: '7',
    price: '5.99',
    imageUrl:
        'https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=400',
    tags: ['Healthy', 'Drinks', 'Vegan'],
    category: Category.drink,
    isAvailable: true,
  ),

  // Coffee Corner Items
  MenuItem(
    id: '47',
    name: 'Cappuccino',
    description: 'Espresso with steamed milk and foam',
    vendorId: '8',
    price: '4.49',
    imageUrl:
        'https://images.unsplash.com/photo-1534778101976-62847782c213?w=400',
    tags: ['Coffee', 'Drinks', 'Hot'],
    category: Category.drink,
    isAvailable: true,
  ),
  MenuItem(
    id: '48',
    name: 'Blueberry Muffin',
    description: 'Freshly baked muffin with blueberries',
    vendorId: '8',
    price: '3.49',
    imageUrl:
        'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=400',
    tags: ['Breakfast', 'Pastries', 'Sweet'],
    category: Category.snack,
    isAvailable: true,
  ),
  MenuItem(
    id: '49',
    name: 'Avocado Toast',
    description: 'Whole grain toast with smashed avocado and egg',
    vendorId: '8',
    price: '7.99',
    imageUrl:
        'https://images.unsplash.com/photo-1603046891744-76e6481cf539?w=400',
    tags: ['Breakfast', 'Healthy', 'Meals'],
    category: Category.meal,
    isAvailable: true,
  ),

  // Drinks
  MenuItem(
    id: '11',
    name: 'Coca Cola',
    description: 'Classic soft drink',
    vendorId: '2',
    price: '1.99',
    imageUrl: 'https://images.unsplash.com/photo-1551538827-9c037cb4f32a?w=400',
    tags: ['Drinks', 'Soft Drinks'],
    category: Category.drink,
    isAvailable: true,
  ),
  MenuItem(
    id: '12',
    name: 'Fresh Orange Juice',
    description: 'Freshly squeezed orange juice',
    vendorId: '4',
    price: '3.99',
    imageUrl:
        'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=400',
    tags: ['Drinks', 'Healthy', 'Fresh'],
    category: Category.drink,
    isAvailable: true,
  ),
  MenuItem(
    id: '13',
    name: 'Iced Coffee',
    description: 'Cold brew coffee with ice',
    vendorId: '1',
    price: '2.99',
    imageUrl:
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=400',
    tags: ['Drinks', 'Coffee', 'Cold'],
    category: Category.drink,
    isAvailable: true,
  ),
  MenuItem(
    id: '50',
    name: 'Mango Lassi',
    description: 'Yogurt-based drink with mango',
    vendorId: '7',
    price: '4.49',
    imageUrl:
        'https://images.unsplash.com/photo-1626201850133-172a091f4086?w=400',
    tags: ['Drinks', 'Healthy', 'Sweet'],
    category: Category.drink,
    isAvailable: true,
  ),
  MenuItem(
    id: '51',
    name: 'Matcha Latte',
    description: 'Green tea powder with steamed milk',
    vendorId: '8',
    price: '4.99',
    imageUrl:
        'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=400',
    tags: ['Drinks', 'Coffee', 'Hot'],
    category: Category.drink,
    isAvailable: true,
  ),
  MenuItem(
    id: '52',
    name: 'Horchata',
    description: 'Sweet rice milk with cinnamon',
    vendorId: '5',
    price: '3.49',
    imageUrl:
        'https://images.unsplash.com/photo-1541658016709-82535e94bc69?w=400',
    tags: ['Drinks', 'Sweet', 'Mexican'],
    category: Category.drink,
    isAvailable: true,
  ),
];

// Categories
final List<String> foodCategories = [
  'Meals',
  'Drinks',
  'Desserts',
  'Snacks',
  'Healthy',
  'Breakfast',
  'Pizza',
  'Burgers',
  'Sushi',
  'Mexican',
  'Asian',
];

// Helper functions
List<MenuItem> getMenuItemsByCategory(String category) {
  return mockMenuItems
      .where(
        (item) =>
            item.tags.any((tag) => tag.toLowerCase() == category.toLowerCase()),
      )
      .toList();
}

List<MenuItem> getMenuItemsByVendor(String vendorId) {
  return mockMenuItems.where((item) => item.vendorId == vendorId).toList();
}

Vendor? getVendorById(String vendorId) {
  try {
    return mockVendors.firstWhere((vendor) => vendor.id == vendorId);
  } catch (e) {
    return null;
  }
}
