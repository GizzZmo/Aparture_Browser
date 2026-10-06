import 'package:flutter/material.dart';

class EmptySurface extends StatelessWidget {
  const EmptySurface({
    required this.icon,
    required this.title,
    required this.body,
    required this.footnote,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final String footnote;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(body, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(
                footnote,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
