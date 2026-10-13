import 'package:flarum_core/flarum_core.dart' show FlarumApiException;
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

/// A caught [error] in words the reader can act on, in their language: no connection, no answer
/// in time, the forum's firewall, no permission, gone, too many requests, the forum failing.
/// Otherwise the forum's own words (Flarum's validation messages, say), and never the exception's
/// text, which names Dio and the request.
String describeError(BuildContext context, Object? error) {
  final l10n = flarumL10n(context);
  if (error is! FlarumApiException) return l10n.errorUnknown;
  if (error.isTimeout) return l10n.errorTimedOut;
  if (error.isNetworkError) return l10n.errorNoConnection;
  // Flarum answers a 403 with its JSON errors; a page without them is a firewall's (Cloudflare's
  // challenge, say).
  if (error.statusCode == 403 && error.errors.isEmpty) return l10n.errorBlocked;
  if (error.hasDetail) return error.reasons;
  return switch (error.statusCode!) {
    401 || 403 => l10n.errorNotAllowed,
    404 || 410 => l10n.errorNotFound,
    429 => l10n.errorRateLimited,
    >= 500 => l10n.errorForumDown,
    _ => l10n.errorUnknown,
  };
}
