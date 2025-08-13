import 'package:flutter/material.dart';

class GtCard extends StatelessWidget {
  const GtCard({
    super.key,
    required this.title,
    this.toptitle,
    this.subtitle,
    this.trailing,
    this.leading,
    this.isSelected = false,
    this.onTap,
    this.onSecondaryTap,
    this.onLongPress,
    this.isStriked = false,
  });
  final Widget? trailing;
  final Widget? leading;
  final String title;
  final String? toptitle;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onLongPress;
  final bool isStriked;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Opacity(
      opacity: isStriked ? 0.40 : 1.0,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: colorScheme.secondary, width: 2)
              : BorderSide.none,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onSecondaryTap: onSecondaryTap,
            onLongPress: onLongPress,
            onTap: onTap,
            hoverColor: colorScheme.secondary.withAlpha(50),
            splashColor: colorScheme.secondary,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (leading != null) leading!,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (toptitle != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              toptitle!,
                              style: textTheme.labelSmall,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            title,
                            style: textTheme.labelLarge,
                          ),
                        ),
                        Text(
                          subtitle ?? '',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
