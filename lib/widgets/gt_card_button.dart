import 'package:flutter/material.dart';

class GtCardButton extends StatelessWidget {
  const GtCardButton({
    super.key,
    required this.child,
    this.onTap,
  });
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.secondary,
            width: 4,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          hoverColor: colorScheme.secondary.withAlpha(50),
          splashColor: colorScheme.secondary,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
