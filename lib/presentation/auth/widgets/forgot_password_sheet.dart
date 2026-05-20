import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';

class ForgotPasswordSheet extends ConsumerStatefulWidget {
  final String email;
  final DateTime? lastEmailSentTime;
  final VoidCallback onEmailSent;

  const ForgotPasswordSheet({
    super.key,
    required this.email,
    this.lastEmailSentTime,
    required this.onEmailSent,
  });

  @override
  ConsumerState<ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends ConsumerState<ForgotPasswordSheet> {
  bool _isSending = false;
  bool _emailSent = false;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _checkRemainingTime();
    _sendEmail();
  }

  void _checkRemainingTime() {
    if (widget.lastEmailSentTime != null) {
      final difference = DateTime.now().difference(widget.lastEmailSentTime!);
      if (difference.inSeconds < 60) {
        setState(() {
          _remainingSeconds = 60 - difference.inSeconds;
        });
        _startCountdown();
      }
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        _startCountdown();
      }
    });
  }

  Future<void> _sendEmail() async {
    setState(() {
      _isSending = true;
    });

    await ref.read(authProvider.notifier).forgotPassword(widget.email);

    if (mounted) {
      setState(() {
        _isSending = false;
        _emailSent = true;
        _remainingSeconds = 60;
      });
      widget.onEmailSent();
      _startCountdown();
    }
  }

  Future<void> _resendEmail() async {
    if (_remainingSeconds > 0) return;
    await _sendEmail();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.35,
            maxChildSize: 0.5,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withAlpha(128),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Password Reset',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.email_outlined,
                                            color: colorScheme.primary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              widget.email,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_isSending)
                              const Center(child: CircularProgressIndicator())
                            else if (_emailSent) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Password reset email has been sent',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              if (_remainingSeconds > 0)
                                Text(
                                  'Resend available in $_remainingSeconds seconds',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurface.withAlpha(
                                          179,
                                        ),
                                      ),
                                )
                              else
                                TextButton.icon(
                                  onPressed: _resendEmail,
                                  icon: const Icon(Icons.refresh, size: 24),
                                  label: const Text('Resend Email'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: colorScheme.primary,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_emailSent)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 32.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'Okay',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
