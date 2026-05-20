import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const Center(
        child: ThreeDotLoadingIndicator(
          orbitRadius: 12,
          dotSize: 6,
          spinDuration: Duration(seconds: 1),
        ),
      ),
    );
  }
}
