class Vendor {
  final String id;
  final String? name;
  final String? phone;
  final String? description;
  final String? location;
  final bool isOpen;
  final String? imageUrl;
  final List<String> tags;
  final String? code; // Vendor authentication code

  Vendor({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.phone,
    required this.isOpen,
    required this.imageUrl,
    required this.tags,
    this.code,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    List<String> tags = (json['tags'] as Iterable<dynamic>)
        .map((e) => e.toString())
        .toList();
    return Vendor(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      phone: json['phone'],
      isOpen: json['is_open'],
      imageUrl: json['image_url'],
      tags: tags,
      code: json['code'],
    );
  }

  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor.fromJson(map);
  }

  factory Vendor.empty() {
    return Vendor(
      id: '',
      name: '',
      description: '',
      location: '',
      phone: '',
      isOpen: false,
      imageUrl: '',
      tags: [],
      code: null,
    );
  }

  Vendor copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    String? phone,
    bool? isOpen,
    String? imageUrl,
    List<String>? tags,
    String? code,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      isOpen: isOpen ?? this.isOpen,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      code: code ?? this.code,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'phone': phone,
      'is_open': isOpen,
      'image_url': imageUrl,
      'tags': tags,
      'code': code,
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'phone': phone,
      'is_open': isOpen,
      'image_url': imageUrl,
      'tags': tags,
    };
  }
}
