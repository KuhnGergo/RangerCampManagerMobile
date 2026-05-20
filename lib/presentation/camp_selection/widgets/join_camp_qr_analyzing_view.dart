import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api_exception_types.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';
import 'package:mastercs_mobile/utils/validators.dart';

class JoinCampQrAnalyzingView extends ConsumerStatefulWidget {
  final String qrValue;
  final VoidCallback onBackToScanning;
  final VoidCallback onJoinSuccess;

  const JoinCampQrAnalyzingView({
    super.key,
    required this.qrValue,
    required this.onBackToScanning,
    required this.onJoinSuccess,
  });

  @override
  ConsumerState<JoinCampQrAnalyzingView> createState() =>
      _JoinCampQrAnalyzingViewState();
}

class _JoinCampQrAnalyzingViewState
    extends ConsumerState<JoinCampQrAnalyzingView> {
  bool _isJoining = true;
  String? _errorMessage;
  String? _joinCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analyzeAndJoin();
    });
  }

  Future<void> _analyzeAndJoin() async {
    final extractedJoinCode = _extractJoinCode(widget.qrValue);

    if (extractedJoinCode == null) {
      setState(() {
        _isJoining = false;
        _errorMessage =
            'Invalid QR format. This QR code does not belong to this app.';
      });
      return;
    }

    setState(() {
      _joinCode = extractedJoinCode;
      _isJoining = true;
      _errorMessage = null;
    });

    try {
      await ref.read(campActionsProvider.notifier).joinCamp(extractedJoinCode);
      if (mounted) {
        widget.onJoinSuccess();
      }
    } on NotFoundException {
      setState(() {
        _isJoining = false;
        _errorMessage = 'Camp does not exist.';
      });
    } catch (e) {
      setState(() {
        _isJoining = false;
        _errorMessage = 'Could not join camp. Please try again.';
      });
    }
  }

  String? _extractJoinCode(String rawValue) {
    final trimmed = rawValue.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return null;
    }

    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (segments.isEmpty) {
      return null;
    }

    final joinCode = segments.last.trim();
    if (Validators.joinCode(joinCode) != null) {
      return null;
    }

    return joinCode;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Analyzing QR Code',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_joinCode != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join Code Found',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _joinCode!,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                if (_joinCode != null) const SizedBox(height: 16),
                if (_isJoining) ...[
                  ThreeDotLoadingIndicator(
                    color: colorScheme.primary,
                    size: 24,
                    dotSize: 6,
                    orbitRadius: 15,
                  ),
                  const SizedBox(height: 16),
                  const Text('Joining camp...', textAlign: TextAlign.center),
                ],
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                OutlinedButton.icon(
                  onPressed: _isJoining ? null : widget.onBackToScanning,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Scanning'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
