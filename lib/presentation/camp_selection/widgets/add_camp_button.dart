import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/camp_selection/controllers/choose_camp_controller.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';

/// A bottom-aligned button that expands to show camp joining options
class AddCampButton extends ConsumerStatefulWidget {
  const AddCampButton({super.key});

  @override
  ConsumerState<AddCampButton> createState() => _AddCampButtonState();
}

class _AddCampButtonState extends ConsumerState<AddCampButton>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleOptionTap(String option) {
    _toggleExpanded();
    // Navigate based on option
    switch (option) {
      case 'code':
        Navigator.of(context).pushNamed('/join-camp');
        break;
      case 'qr':
        Navigator.of(context).pushNamed('/join-camp-qr');
        break;
      case 'create':
        Navigator.of(context).pushNamed('/create-camp');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chooseCampState = ref.watch(chooseCampControllerProvider);
    final chooseCampController = ref.read(
      chooseCampControllerProvider.notifier,
    );

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                return ClipRect(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: _expandAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildOption(
                            context,
                            icon: Icons.qr_code_scanner,
                            title: 'Join with QR Code',
                            subtitle: 'Scan a camp QR code',
                            onTap: () => _handleOptionTap('qr'),
                          ),
                          Divider(height: 5, color: Colors.transparent),
                          _buildOption(
                            context,
                            icon: Icons.pin,
                            title: 'Join with Code',
                            subtitle: 'Enter a camp join code',
                            onTap: () => _handleOptionTap('code'),
                          ),
                          Divider(height: 5, color: Colors.transparent),
                          _buildOption(
                            context,
                            icon: Icons.add_circle_outline,
                            title: 'Create Your Own Camp',
                            subtitle: 'Start a new camp',
                            onTap: () => _handleOptionTap('create'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Center add button
                    GestureDetector(
                      onTap: _toggleExpanded,
                      child: AnimatedRotation(
                        turns: _isExpanded ? 0.125 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            size: 40,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: MediaQuery.of(context).size.width / 2 - 90,
                      bottom: 0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: chooseCampState.isLoading
                            ? null
                            : () {
                                chooseCampController.refreshCamps();
                              },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: chooseCampState.isLoading
                              ? SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: const ThreeDotLoadingIndicator(
                                      size: 18,
                                      dotSize: 4,
                                      orbitRadius: 8,
                                      spinDuration: Duration(milliseconds: 600),
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.refresh,
                                  size: 30,
                                  color: colorScheme.onSurface,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),

      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
