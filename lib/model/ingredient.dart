const String tableIngredient = 'ingredient';

class IngredientFields {
  static final List<String> values = [id, nameEng, nameKor, categoryId, scan];

  static const String id = '_id';
  static const String nameEng = 'name_eng';
  static const String nameKor = 'name_kor';
  static const String categoryId = 'category_id';
  static const String scan = 'scan';
}

class Ingredient {
  final int? id;
  final String nameEng;
  final String nameKor;
  final int categoryId;
  final bool scan;

  Ingredient({
    this.id,
    required this.nameEng,
    required this.nameKor,
    required this.categoryId,
    required this.scan,
  });

  static Ingredient fromJson(Map<String, Object?> json) => Ingredient(
        id: json[IngredientFields.id] as int?,
        nameEng: json[IngredientFields.nameEng] as String,
        nameKor: json[IngredientFields.nameKor] as String,
        categoryId: json[IngredientFields.categoryId] as int,
        scan: json[IngredientFields.scan] == 1,
      );

  Map<String, Object?> toJson() => {
        IngredientFields.id: id,
        IngredientFields.nameEng: nameEng,
        IngredientFields.nameKor: nameKor,
        IngredientFields.categoryId: categoryId,
        IngredientFields.scan: scan ? 1 : 0,
      };

  Ingredient copy({
    int? id,
    String? nameEng,
    String? nameKor,
    int? categoryId,
    bool? scan,
  }) =>
      Ingredient(
        id: id ?? this.id,
        nameEng: nameEng ?? this.nameEng,
        nameKor: nameKor ?? this.nameKor,
        categoryId: categoryId ?? this.categoryId,
        scan: scan ?? this.scan,
      );
}
