import 'package:flutter/material.dart';
import 'package:mastercs_mobile/l10n/app_localizations.dart';

extension L10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
