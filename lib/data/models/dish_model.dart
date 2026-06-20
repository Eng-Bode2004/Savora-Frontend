/// Dish model used by the Chef menu-management screens.
///
/// Also re-exports the recipe sub-models (RecipeModel, RecipeIngredient,
/// RecipeStep, RecipeQualityCheck) and the catalog helper CatalogRecipeModel
/// so consumers only need one import.

class DishModel {
  const DishModel({
    required this.id,
    required this.name,
    this.imageUrl =
        'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
    this.inStock = true,
    this.recipe,
  });

  final String id;
  final String name;
  final String imageUrl;
  final bool inStock;
  final RecipeModel? recipe;

  /// Whether this dish has a certified Savora Standard recipe attached.
  bool get isCertifiedStandard => recipe != null;

  DishModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    bool? inStock,
    RecipeModel? recipe,
  }) {
    return DishModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      inStock: inStock ?? this.inStock,
      recipe: recipe ?? this.recipe,
    );
  }
}

// ── Recipe sub-models ──

class RecipeModel {
  const RecipeModel({
    required this.category,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.prepTimeMinutes,
    required this.servings,
    this.ingredients = const [],
    this.steps = const [],
    this.qualityChecks = const [],
  });

  final String category;
  final String title;
  final String description;
  final String imageUrl;
  final int prepTimeMinutes;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final List<RecipeQualityCheck> qualityChecks;
}

class RecipeIngredient {
  const RecipeIngredient({required this.id, required this.label});

  final String id;
  final String label;
}

class RecipeStep {
  const RecipeStep({
    required this.order,
    required this.title,
    required this.description,
  });

  final int order;
  final String title;
  final String description;
}

class RecipeQualityCheck {
  const RecipeQualityCheck({required this.label});

  final String label;
}

/// Wrapper passed through Navigator arguments to RecipeDetailScreen.
class RecipeDetailArgs {
  const RecipeDetailArgs(this.dish);
  final DishModel dish;
}

// ── Catalog recipe model (onboarding menu selection) ──

class CatalogRecipeModel {
  const CatalogRecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.isHighDemand = false,
    this.selected = false,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final bool isHighDemand;
  final bool selected;

  CatalogRecipeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    bool? isHighDemand,
    bool? selected,
  }) {
    return CatalogRecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isHighDemand: isHighDemand ?? this.isHighDemand,
      selected: selected ?? this.selected,
    );
  }
}
