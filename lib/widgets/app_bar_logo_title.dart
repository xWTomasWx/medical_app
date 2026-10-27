import 'package:flutter/material.dart';

class AppBarLogoTitle extends StatelessWidget {
  final String title;

  const AppBarLogoTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            'lib/icons/logopng.png',
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            semanticLabel: 'Logo de Citas Médicas',
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}