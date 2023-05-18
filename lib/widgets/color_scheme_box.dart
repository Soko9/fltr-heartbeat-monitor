import 'package:flutter/material.dart';

class ColorSchemeBox extends StatelessWidget {
  const ColorSchemeBox({
    super.key,
    required this.onPress,
    required this.lightColor,
    required this.darkColor,
  });

  final GestureTapCallback onPress;
  final Color lightColor;
  final Color darkColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: 35.0,
        height: 35.0,
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        padding: const EdgeInsets.all(0.0),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: darkColor,
          border: Border.all(
            width: 0.0,
            color: Colors.transparent,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        child: Container(
          width: 17.5,
          height: 35.0,
          decoration: BoxDecoration(
            color: lightColor,
            border: Border.all(
              width: 0.0,
              color: Colors.transparent,
            ),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0)),
          ),
        ),
      ),
    );
  }
}
