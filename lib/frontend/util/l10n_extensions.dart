import 'package:confidants/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Resolves a localized string once an [AppLocalizations] is available.
/// Lets `const` named constructors reference translations by key instead of
/// hard-coded literals (they can't read from a [BuildContext] themselves).
typedef L10nText = String Function(AppLocalizations l10n);

extension L10nBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
