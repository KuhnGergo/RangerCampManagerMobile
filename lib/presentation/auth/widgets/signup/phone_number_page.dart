import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/components/widgets/phone_number_input_field.dart';
import 'package:mastercs_mobile/presentation/auth/widgets/signup/signup_page_container.dart';

class PhoneNumberPage extends StatefulWidget {
  final String? initialValue;
  final Function(String?) onNext;
  final VoidCallback onSkip;
  final VoidCallback onBack;
  final VoidCallback? onBackToSummary;
  final bool isOnline;
  final VoidCallback? onShowOfflineToast;

  const PhoneNumberPage({
    super.key,
    this.initialValue,
    required this.onNext,
    required this.onSkip,
    required this.onBack,
    this.onBackToSummary,
    this.isOnline = true,
    this.onShowOfflineToast,
  });

  @override
  State<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  String? _phoneNumber;
  bool _isPhoneValid = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue?.trim();
    _phoneNumber = (initial == null || initial.isEmpty) ? null : initial;
  }

  void _submit() {
    final error = _phoneNumber != null && !_isPhoneValid
        ? 'Please enter a valid phone number'
        : null;
    setState(() {
      _errorText = error;
    });

    if (error == null) {
      widget.onNext(_phoneNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SignupPageContainer(
      onNext: _submit,
      onSkip: widget.onSkip,
      onBackToSummary: widget.onBackToSummary,
      isOnline: widget.isOnline,
      onBack: widget.onBack,
      onShowOfflineToast: widget.onShowOfflineToast,
      showSkip: true,
      hasValue: _phoneNumber != null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_outlined,
            size: 80,
            color: colorScheme.primary.withAlpha(179),
          ),
          const SizedBox(height: 32),
          PhoneNumberInputField(
            labelText: 'Phone Number',
            hintText: 'Enter phone number',
            initialValue: widget.initialValue,
            errorText: _errorText,
            onChanged: (value) {
              setState(() {
                _phoneNumber = value;
                if (_errorText != null) {
                  _errorText = null;
                }
              });
            },
            onValidationChanged: (isValid) {
              setState(() {
                _isPhoneValid = isValid;
                if (_errorText != null && (_phoneNumber == null || isValid)) {
                  _errorText = null;
                }
              });
            },
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
    );
  }
}
