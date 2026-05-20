import 'dart:ui';

import 'package:dlibphonenumber/dlibphonenumber.dart' as p;
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';

class PhoneNumberInputField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final String? initialValue;
  final bool enabled;
  final bool autofocus;
  final String? errorText;
  final ValueChanged<String?> onChanged;
  final ValueChanged<bool>? onValidationChanged;
  final ValueChanged<String>? onSubmitted;

  const PhoneNumberInputField({
    super.key,
    required this.labelText,
    this.hintText,
    this.initialValue,
    this.enabled = true,
    this.autofocus = false,
    this.errorText,
    required this.onChanged,
    this.onValidationChanged,
    this.onSubmitted,
  });

  @override
  State<PhoneNumberInputField> createState() => _PhoneNumberInputFieldState();
}

class _PhoneNumberInputFieldState extends State<PhoneNumberInputField> {
  late final TextEditingController _controller;
  late PhoneNumber _currentNumber;
  late String _currentIsoCode;
  late int _maxLength;
  late String _lengthHint;

  @override
  void initState() {
    super.initState();

    final initial = widget.initialValue?.trim();
    _controller = TextEditingController(text: initial ?? '');

    _currentIsoCode =
        _extractIsoCodeFromInitialPhone(initial) ??
        _resolveIsoCodeFromMetadata();
    _currentNumber = PhoneNumber(
      isoCode: _currentIsoCode,
      phoneNumber: initial,
    );
    _recomputeLengthRules(_currentIsoCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _emitCurrentValue() {
    final hasInput = _controller.text.trim().isNotEmpty;
    final normalized = _currentNumber.phoneNumber?.trim();
    widget.onChanged(hasInput ? normalized : null);
  }

  String? _extractIsoCodeFromInitialPhone(String? initialPhoneNumber) {
    if (initialPhoneNumber == null || initialPhoneNumber.isEmpty) {
      return null;
    }

    final phoneUtil = p.PhoneNumberUtil.instance;
    try {
      final parsedNumber = phoneUtil.parse(initialPhoneNumber, null);
      final detectedIsoCode = phoneUtil
          .getRegionCodeForNumber(parsedNumber)
          ?.toUpperCase();
      if (detectedIsoCode != null && _hasRegionMetadata(detectedIsoCode)) {
        return detectedIsoCode;
      }
    } catch (_) {
      // Ignore parse failures and continue with metadata-based fallback.
    }

    return null;
  }

  String _resolveIsoCodeFromMetadata() {
    final deviceCountryCode = PlatformDispatcher.instance.locale.countryCode
        ?.toUpperCase();
    if (deviceCountryCode != null && _hasRegionMetadata(deviceCountryCode)) {
      return deviceCountryCode;
    }

    return 'US';
  }

  bool _hasRegionMetadata(String isoCode) {
    final metadata = p.PhoneNumberUtil.instance.getMetadataForRegion(
      regionCode: isoCode,
    );
    return metadata != null;
  }

  void _recomputeLengthRules(String isoCode) {
    final metadata = p.PhoneNumberUtil.instance.getMetadataForRegion(
      regionCode: isoCode,
    );

    final mobileLengths =
        metadata?.mobile.possibleLength.where((len) => len > 0).toList() ??
        <int>[];

    final fallbackLengths =
        metadata?.generalDesc.possibleLength.where((len) => len > 0).toList() ??
        <int>[];

    final lengths = (mobileLengths.isNotEmpty ? mobileLengths : fallbackLengths)
      ..sort();

    if (lengths.isEmpty) {
      _maxLength = 15;
      _lengthHint = 'Max 15 digits';
      return;
    }

    _maxLength = lengths.last;
    final minLength = lengths.first;
    final maxLength = lengths.last;
    _lengthHint = minLength == maxLength
        ? 'Expected $maxLength digits'
        : 'Expected $minLength-$maxLength digits';
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return InternationalPhoneNumberInput(
      textFieldController: _controller,
      initialValue: _currentNumber,
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        useBottomSheetSafeArea: true,
        leadingPadding: 8,
        trailingSpace: false,
      ),
      autoValidateMode: AutovalidateMode.disabled,
      ignoreBlank: true,
      formatInput: true,
      // The package's maxLength includes the country code, so we need to add its length to our computed max.
      maxLength:
          _maxLength +
          (_currentNumber.dialCode != null
              ? _currentNumber.dialCode!.replaceAll('+', '').length
              : 0),
      isEnabled: widget.enabled,
      autoFocus: widget.autofocus,
      keyboardAction: TextInputAction.done,
      selectorTextStyle: TextStyle(color: themeData.colorScheme.onSurface),
      inputDecoration: getFormFieldDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        themeData: themeData,
        errorText: widget.errorText,
        enabled: widget.enabled,
      ).copyWith(helperText: _lengthHint),
      onInputChanged: (phoneNumber) {
        final nextIsoCode = (phoneNumber.isoCode ?? _currentIsoCode)
            .toUpperCase();
        if (nextIsoCode != _currentIsoCode) {
          setState(() {
            _currentIsoCode = nextIsoCode;
            _recomputeLengthRules(_currentIsoCode);
          });
        }
        _currentNumber = phoneNumber;
        _emitCurrentValue();
      },
      onInputValidated: (isValid) {
        widget.onValidationChanged?.call(isValid);
      },
      onFieldSubmitted: (value) {
        widget.onSubmitted?.call(value);
      },
      searchBoxDecoration: getFormFieldDecoration(
        labelText: 'Search Country',
        themeData: themeData,
        enabled: true,
      ),
    );
  }
}
