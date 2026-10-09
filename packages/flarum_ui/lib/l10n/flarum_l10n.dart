import 'package:flutter/widgets.dart';

import 'generated/flarum_localizations.dart';

export 'generated/flarum_localizations.dart';

/// flarum_ui's strings in [context]'s language.
///
/// Uses [FlarumLocalizations.delegate] when the app registered it, and
/// otherwise looks the strings up directly, so a test or a host that only
/// registers its own delegates still gets them. Falls back to English for a
/// language flarum_ui doesn't have.
FlarumLocalizations flarumL10n(BuildContext context) {
  final registered = FlarumLocalizations.of(context);
  if (registered != null) return registered;
  final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
  return lookupFlarumLocalizations(FlarumLocalizations.delegate.isSupported(locale) ? locale : const Locale('en'));
}
