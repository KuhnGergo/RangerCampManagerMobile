import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/signup/signup_page_container.dart';
import 'package:mastercs_mobile/utils/validators.dart';

class UsernamePage extends StatefulWidget {
  final String initialValue;
  final Function(String) onNext;
  final VoidCallback onBack;
  final VoidCallback? onBackToSummary;
  final bool isOnline;
  final VoidCallback? onShowOfflineToast;

  const UsernamePage({
    super.key,
    required this.initialValue,
    required this.onNext,
    required this.onBack,
    this.onBackToSummary,
    this.isOnline = true,
    this.onShowOfflineToast,
  });

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final error = Validators.username(_controller.text);
    setState(() {
      _errorText = error;
    });

    if (error == null) {
      widget.onNext(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SignupPageContainer(
      onNext: _submit,
      onBack: widget.onBack,
      onBackToSummary: widget.onBackToSummary,
      isOnline: widget.isOnline,
      onShowOfflineToast: widget.onShowOfflineToast,
      header: Column(
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: colorScheme.primary.withAlpha(179),
          ),
          const SizedBox(height: 32),
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            onChanged: (_) {
              if (_errorText != null) {
                setState(() {
                  _errorText = null;
                });
              }
            },
            onSubmitted: (_) => _submit(),
            decoration: getFormFieldDecoration(
              labelText: 'Username',
              themeData: Theme.of(context),
              errorText: _errorText,
              suffixIcon: const Icon(Icons.badge_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
