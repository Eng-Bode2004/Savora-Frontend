import 'package:flutter/material.dart';
import 'package:savora_app/core/routing/routes.dart'
    hide OrderPreparationArgs, RecipeDetailArgs;
import 'package:savora_app/data/models/order_model.dart';
import 'package:savora_app/data/models/dish_model.dart';
import 'package:savora_app/features/chef/shell/chef_shell.dart';
import 'package:savora_app/features/chef/auth/screens/location_setup_screen.dart';
import 'package:savora_app/features/chef/menu_submission/screens/menu_selection_screen.dart';
import 'package:savora_app/features/chef/orders/screens/order_preparation_screen.dart';
import 'package:savora_app/features/chef/menu_submission/screens/recipe_detail_screen.dart';

import 'package:savora_app/features/chef/menu_submission/screens/culinary_specialty_screen.dart';
import 'package:savora_app/features/customer/auth/screens/role_selection_screen.dart';
import 'package:savora_app/features/chef/auth/screens/daily_orders_screen.dart';
import 'package:savora_app/features/chef/auth/screens/id_photo_screen.dart';
import 'package:savora_app/features/chef/auth/screens/waiting_approval_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.roleSelection:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
          settings: settings,
        );
      case Routes.chefCulinarySpecialty:
        return MaterialPageRoute(
          builder: (_) => const CulinarySpecialtyScreen(),
          settings: settings,
        );
      case Routes.chefDailyOrders:
        return MaterialPageRoute(
          builder: (_) => const DailyOrdersScreen(),
          settings: settings,
        );
      case Routes.chefIdPhoto:
        return MaterialPageRoute(
          builder: (_) => const IdPhotoScreen(profileId: null),
          settings: settings,
        );
      case Routes.chefLocationSelection:
        return MaterialPageRoute(
          builder: (_) => const LocationSetupScreen(),
          settings: settings,
        );
      case Routes.chefWaitingApproval:
        return MaterialPageRoute(
          builder: (_) => const WaitingApprovalScreen(),
          settings: settings,
        );
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
