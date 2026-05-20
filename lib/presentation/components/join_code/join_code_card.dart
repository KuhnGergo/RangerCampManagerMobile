import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/text_update_dialog.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/utils/validators.dart';

class JoinCodeCard extends ConsumerStatefulWidget {
  final String joinCode;
  final bool hasCopyAction;
  final bool hasChangeAction;
  final Future<void> Function(String)? onChange;

  const JoinCodeCard({
    super.key,
    required this.joinCode,
    this.hasChangeAction = false,
    this.hasCopyAction = true,
    this.onChange,
  });

  @override
  ConsumerState<JoinCodeCard> createState() => _JoinCodeCardState();
}

class _JoinCodeCardState extends ConsumerState<JoinCodeCard> {
  String get joinCode => widget.joinCode;
  bool _copied = false;

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: joinCode));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _showChangeDialog(BuildContext context) {
    Navigator.of(context).pop(); // Close the bottom sheet before showing dialog
    if (widget.onChange == null) {
      showError(context, 'Change action is not set');
      return;
    }
    showTextUpdateDialog(
      context: context,
      errorContext: context,
      title: 'Change Join Code',
      label: 'Join Code',
      initialValue: widget.joinCode,
      hintText: 'Enter join code',
      maxLength: 12,
      validator: (value) => Validators.joinCode(value),
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      confirmAction: widget.onChange!,
      genericErrorMessage: 'Failed to update join code',
      badRequestMessage: 'Join code already in use.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      child: InkWell(
        onTap: _copied ? null : () => _copyToClipboard(context),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withAlpha(50),
                blurRadius: 2,
                offset: const Offset(0, 2),
                inset: true,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                // Leading icon
                Icon(
                  Icons.vpn_key_outlined,
                  color: colorScheme.onSurface.withAlpha(200),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  'Join Code:',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  joinCode,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    letterSpacing: 1.2,
                  ),
                ),

                const Spacer(),
                const SizedBox(width: 8),

                // Actions - dynamically rendered based on integrated actions
                if (widget.hasCopyAction)
                  IconButton(
                    onPressed: _copied ? null : () => _copyToClipboard(context),
                    icon: Icon(
                      _copied ? Icons.check : Icons.copy,
                      size: 18,
                      color: colorScheme.onSurface,
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),

                if (widget.hasChangeAction) ...[
                  if (widget.hasCopyAction)
                    IconButton(
                      onPressed: () => _showChangeDialog(context),
                      icon: Icon(
                        Icons.mode_edit_outlined,
                        size: 18,
                        color: colorScheme.onSurface,
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
