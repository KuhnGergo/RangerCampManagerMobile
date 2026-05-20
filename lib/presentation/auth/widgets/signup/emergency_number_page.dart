import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/signup/signup_page_container.dart';

class EmergencyNumberPage extends StatefulWidget {
  final String? initialValue;
  final Future<void> Function(String?) onFinish;
  final Future<void> Function() onSkip;
  final VoidCallback onBack;
  final VoidCallback? onBackToSummary;
  final bool isOnline;
  final VoidCallback? onShowOfflineToast;

  const EmergencyNumberPage({
    super.key,
    this.initialValue,
    required this.onFinish,
    required this.onSkip,
    required this.onBack,
    this.onBackToSummary,
    this.isOnline = true,
    this.onShowOfflineToast,
  });

  @override
  State<EmergencyNumberPage> createState() => _EmergencyNumberPageState();
}

class _EmergencyNumberPageState extends State<EmergencyNumberPage> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String? _errorText;
  bool _isSubmitting = false;

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

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    // Basic phone validation - at least 10 digits
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  Future<void> _submit() async {
    final error = _validatePhone(_controller.text);
    setState(() {
      _errorText = error;
    });

    if (error == null) {
      setState(() {
        _isSubmitting = true;
      });
      await widget.onFinish(_controller.text.isEmpty ? null : _controller.text);
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _skip() async {
    setState(() {
      _isSubmitting = true;
    });
    await widget.onSkip();
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SignupPageContainer(
      onNext: _submit,
      onSkip: _skip,
      onBack: widget.onBack,
      onBackToSummary: widget.onBackToSummary,
      isOnline: widget.isOnline,
      onShowOfflineToast: widget.onShowOfflineToast,
      showSkip: true,
      hasValue: _controller.text.isNotEmpty,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emergency_outlined,
            size: 80,
            color: colorScheme.primary.withAlpha(179),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.phone,
            enabled: !_isSubmitting,
            onChanged: (_) {
              if (_errorText != null) {
                setState(() {
                  _errorText = null;
                });
              }
              setState(() {});
            },
            onSubmitted: (_) => _submit(),
            decoration: getFormFieldDecoration(
              labelText: 'Emergency Contact Number',
              themeData: Theme.of(context),
              errorText: _errorText,
              suffixIcon: const Icon(Icons.contact_phone),
            ),
          ),
        ],
      ),
    );
  }
}
