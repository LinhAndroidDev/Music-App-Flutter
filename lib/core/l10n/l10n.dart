import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Supported locales (ServiceMusic currently ships Vietnamese only).
abstract final class AppLocales {
  static const vi = Locale('vi');

  static const all = [vi];
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
