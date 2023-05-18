import 'package:flutter/material.dart';

class AthleteSwitch extends StatelessWidget {
  const AthleteSwitch({
    super.key,
    required this.isAthlete,
    required this.onSwitch,
  });

  final bool isAthlete;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onSwitch,
      child: Container(
        height: 40.0,
        margin: const EdgeInsets.all(12.0),
        constraints: const BoxConstraints(maxWidth: 120.0),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2.0,
            color: isAthlete ? Colors.green : Colors.amber,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                isAthlete ? "YES" : "NOT YET",
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium!.copyWith(
                  color: isAthlete ? Colors.green : Colors.amber,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              height: 40.0,
              width: 20.0,
              decoration: BoxDecoration(
                color: isAthlete ? Colors.green : Colors.amber,
                border: Border.all(
                  width: 0.0,
                  color: isAthlete ? Colors.green : Colors.amber,
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isAthlete ? Colors.green : Colors.amber,
                    blurRadius: 5.0,
                    spreadRadius: 2.0,
                  ),
                  BoxShadow(
                    color: isAthlete ? Colors.green : Colors.amber,
                    blurRadius: 2.5,
                    spreadRadius: -2.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
