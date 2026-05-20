import 'package:flutter/material.dart';

class SignupPageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const SignupPageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= currentPage
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}
