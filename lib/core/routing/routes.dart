import '../../data/models/dish_model.dart';
import '../../data/models/order_model.dart';

class Routes {
  Routes._();

  static const String chefShell = '/chef/shell';
  static const String chefRecipeDetail = '/chef/recipe-detail';
  static const String chefOrderPreparation = '/chef/order-preparation';
  static const String chefMenuSelection = '/chef/menu-selection';
  static const String chefLocationSetup = '/chef/location-setup';
  static const String roleSelection = '/role-selection';
  static const String chefCulinarySpecialty = '/chef/culinary-specialty';
  static const String chefDailyOrders = '/chef/daily-orders';
  static const String chefIdPhoto = '/chef/id-photo';
  static const String chefLocationSelection = '/chef/location-selection';
  static const String chefWaitingApproval = '/chef/waiting-approval';
}

class RecipeDetailArgs {
  final DishModel dish;
  const RecipeDetailArgs(this.dish);
}

class OrderPreparationArgs {
  final OrderModel order;
  const OrderPreparationArgs(this.order);
}
