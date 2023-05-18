import 'package:flutter/material.dart';

class CupButton extends StatelessWidget {
  const CupButton({
    super.key,
    required this.onPress,
    required this.text,
  });

  final GestureTapCallback onPress;
  final String text;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          // alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [
            //     ThemeService.kColorLight.value,
            //     ThemeService.kColorLight.value,
            //     ThemeService.kColorDark.value,
            //     ThemeService.kColorDark.value,
            //     ThemeService.kColorDark.value,
            //     ThemeService.kColorLight.value,
            //     ThemeService.kColorLight.value,
            //   ],
            //   begin: Alignment.centerLeft,
            //   end: Alignment.centerRight,
            // ),
            color: theme.primaryColor,
            border: Border.all(
              width: 0.0,
              color: Colors.transparent,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
          child: Text(
            text.toUpperCase(),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
