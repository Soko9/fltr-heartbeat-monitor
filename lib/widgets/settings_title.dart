import 'package:flutter/material.dart';

class SettingsTitle extends StatelessWidget {
  const SettingsTitle({
    super.key,
    required this.title,
    this.margin,
  });

  final String title;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Divider(
            color: theme.primaryColor,
            height: 7.0,
            thickness: 0.8,
            indent: 52.0,
            endIndent: 52.0,
          ),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          Divider(
            color: theme.primaryColor,
            height: 5.0,
            thickness: 0.8,
            indent: 52.0,
            endIndent: 52.0,
          ),
        ],
      ),
    );
  }
}
