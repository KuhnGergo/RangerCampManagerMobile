import 'package:flutter/material.dart';

class EmailSuffixBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSuffixTap;
  final double bottomInset;

  const EmailSuffixBar({
    super.key,
    required this.controller,
    required this.onSuffixTap,
    required this.bottomInset,
  });

  static const List<String> emailSuffixes = ['@gmail.com'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (controller.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 12.0,
          bottom: bottomInset > 0 ? 12.0 : 16.0,
        ),
        color: Colors.transparent,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: emailSuffixes.map((suffix) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Material(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => onSuffixTap(suffix),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      child: Text(
                        suffix,
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
