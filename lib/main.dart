import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app_pages.dart';
import 'core/l10n/l10n.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Music App',
      theme: AppTheme.light(),
      locale: AppLocales.vi,
      fallbackLocale: AppLocales.vi,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocales.all,
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
      debugShowCheckedModeBanner: false,
    );
  }
}
