import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/signup/signup_page_container.dart';
import 'package:mastercs_mobile/utils/validators.dart';

class PasswordPage extends StatefulWidget {
  final String initialPassword;
  final Function(String) onNext;
  final VoidCallback onBack;
  final VoidCallback? onBackToSummary;
  final bool isOnline;
  final VoidCallback? onShowOfflineToast;

  const PasswordPage({
    super.key,
    required this.initialPassword,
    required this.onNext,
    required this.onBack,
    this.onBackToSummary,
    this.isOnline = true,
    this.onShowOfflineToast,
  });

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmFocusNode = FocusNode();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  String? _passwordError;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(text: widget.initialPassword);
    _confirmController = TextEditingController(text: widget.initialPassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final passwordError = Validators.password(_passwordController.text);
    final confirmError = Validators.confirmPassword(
      _confirmController.text,
      _passwordController.text,
    );

    setState(() {
      _passwordError = passwordError;
      _confirmError = confirmError;
    });

    if (passwordError == null && confirmError == null) {
      widget.onNext(_passwordController.text);
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
      body: Column(
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: colorScheme.primary.withAlpha(179),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: !_isPasswordVisible,
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() {
                  _passwordError = null;
                });
              }
            },
            onSubmitted: (_) => _confirmFocusNode.requestFocus(),
            decoration: getFormFieldDecoration(
              labelText: 'Password',
              themeData: Theme.of(context),
              errorText: _passwordError,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmController,
            focusNode: _confirmFocusNode,
            obscureText: !_isConfirmVisible,
            onChanged: (_) {
              if (_confirmError != null) {
                setState(() {
                  _confirmError = null;
                });
              }
            },
            onSubmitted: (_) => _submit(),
            decoration: getFormFieldDecoration(
              labelText: 'Confirm Password',
              themeData: Theme.of(context),
              errorText: _confirmError,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmVisible = !_isConfirmVisible;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
