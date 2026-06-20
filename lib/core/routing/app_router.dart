import 'package:flutter/material.dart';
import 'package:savora_app/core/routing/routes.dart';
import 'package:savora_app/data/models/order_model.dart';
import 'package:savora_app/data/models/dish_model.dart';
import 'package:savora_app/features/chef/shell/chef_shell.dart';
import 'package:savora_app/features/chef/auth/screens/location_setup_screen.dart';
import 'package:savora_app/features/chef/menu_submission/screens/menu_selection_screen.dart';
import 'package:savora_app/features/chef/orders/screens/order_preparation_screen.dart';
import 'package:savora_app/features/chef/menu_submission/screens/recipe_detail_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.chefShell:
        return MaterialPageRoute(
          builder: (_) => const ChefShell(),
          settings: settings,
        );
      case Routes.chefLocationSetup:
        return MaterialPageRoute(
          builder: (_) => const LocationSetupScreen(),
          settings: settings,
        );
      case Routes.chefMenuSelection:
        return MaterialPageRoute(
          builder: (_) => const MenuSelectionScreen(),
          settings: settings,
        );
      case Routes.chefOrderPreparation:
        final args = settings.arguments as OrderPreparationArgs;
        return MaterialPageRoute(
          builder: (_) => OrderPreparationScreen(order: args.order),
          settings: settings,
        );
      case Routes.chefRecipeDetail:
        final args = settings.arguments as RecipeDetailArgs;
        return MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(dish: args.dish),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
