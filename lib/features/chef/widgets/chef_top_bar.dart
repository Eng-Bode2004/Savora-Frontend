import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';

enum ChefTopBarLeading { menu, back, none }

/// The recurring header used across nearly every Chef screen:
/// hamburger/back leading icon, "Savora" wordmark (or a custom title),
/// an optional notification bell, and the chef's avatar.
class ChefTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ChefTopBar({
    super.key,
    this.leading = ChefTopBarLeading.menu,
    this.title,
    this.showNotificationBell = false,
    this.avatarUrl,
    this.onLeadingTap,
    this.onAvatarTap,
    this.onNotificationTap,
  });

  final ChefTopBarLeading leading;
  final String? title;
  final bool showNotificationBell;
  final String? avatarUrl;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = AppColors.textOf(brightness);
    final borderColor = AppColors.borderOf(brightness);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(brightness),
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height - 1,
          child: Row(
            children: [
              if (leading != ChefTopBarLeading.none)
                _LeadingIcon(
                  icon: leading == ChefTopBarLeading.back
                      ? Icons.arrow_back_rounded
                      : Icons.menu_rounded,
                  color: textColor,
                  onTap: onLeadingTap ??
                      (leading == ChefTopBarLeading.back
                          ? () => Navigator.of(context).maybePop()
                          : null),
                ),
              SizedBox(
                  width: leading == ChefTopBarLeading.none ? 0 : AppSpacing.sm),
              Expanded(
                child: Text(
                  title ?? 'Savora',
                  textAlign: leading == ChefTopBarLeading.back
                      ? TextAlign.center
                      : TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTextStyles.headlineMd.copyWith(color: AppColors.amber),
                ),
              ),
              if (showNotificationBell) ...[
                _LeadingIcon(
                  icon: Icons.notifications_none_rounded,
                  color: textColor,
                  onTap: onNotificationTap,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              _Avatar(
                  url: avatarUrl, onTap: onAvatarTap, borderColor: borderColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon, required this.color, this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.borderColor, this.onTap});

  final String? url;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.5),
          gradient: AppColors.accentGradient,
        ),
        clipBehavior: Clip.antiAlias,
        child: url != null
            ? Image.network(url!,
                fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback())
            : _fallback(),
      ),
    );
  }

  Widget _fallback() =>
      const Icon(Icons.person, color: AppColors.clay, size: 20);
}
