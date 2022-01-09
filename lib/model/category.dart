const String tableCategory = 'category';

class CategoryFields {
  static const String id = '_id';
  static const String name = 'name';
}

class Category {
  final int? id;
  final String name;

  Category({
    this.id,
    required this.name,
  });
}
