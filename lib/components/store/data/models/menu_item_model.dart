enum Category { meal, drink, dessert, snack, all }

class MenuItem {
  final String id;
  final String name;
  final String description;
  final String vendorId;
  final String price;
  final String imageUrl;
  final List<String> tags;
  final Category category;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.vendorId,
    required this.price,
    required this.imageUrl,
    required this.tags,
    required this.category,
    required this.isAvailable,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    List<String> tags = (json['tags'] as Iterable<dynamic>)
        .map((e) => e.toString())
        .toList();

    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      vendorId: json['vendor_id'],
      price: json['price'],
      imageUrl: json['image_url'],
      tags: tags,
      category: Category.values.byName(json['category']),
      isAvailable: json['available'],
    );
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem.fromJson(map);
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    String? vendorId,
    String? price,
    String? imageUrl,
    List<String>? tags,
    Category? category,
    bool? isAvailable,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      vendorId: vendorId ?? this.vendorId,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  factory MenuItem.empty() {
    return MenuItem(
      id: '',
      name: '',
      description: '',
      vendorId: '',
      price: '',
      imageUrl: '',
      tags: [],
      category: Category.meal,
      isAvailable: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'vendor_id': vendorId,
      'price': price,
      'image_url': imageUrl,
      'tags': tags,
      'category': category.name,
      'available': isAvailable,
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'description': description,
      'vendor_id': vendorId,
      'price': price,
      'image_url': imageUrl,
      'tags': tags,
      'category': category.name,
      'available': isAvailable,
    };
  }
}
