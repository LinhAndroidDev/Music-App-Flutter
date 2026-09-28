import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app_pages.dart';
import 'app/initial_binding.dart';
import 'core/l10n/l10n.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'core/navigation/app_navigation_route.dart';
import 'modules/player/app_player_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      routingCallback: (routing) {
        if (Get.isRegistered<AppNavigationRoute>()) {
          Get.find<AppNavigationRoute>().updateRoute(routing?.current);
        }
      },
      builder: (context, child) => AppPlayerShell(child: child),
      defaultTransition: Transition.cupertino,
      debugShowCheckedModeBanner: false,
    );
  }
}
