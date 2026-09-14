import 'package:flutter/material.dart';

import '../data/in_memory_tnp_api.dart';
import '../data/tnp_repository.dart';
import '../domain/app_controller.dart';
import '../presentation/home_screen.dart';
import 'theme.dart';

class TnpApp extends StatefulWidget {
  const TnpApp({super.key});

  @override
  State<TnpApp> createState() => _TnpAppState();
}

class _TnpAppState extends State<TnpApp> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    controller = AppController(repository: TnpRepository(api: InMemoryTnpApi()));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'appTNP',
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: controller.themeMode,
          home: HomeScreen(controller: controller),
        );
      },
    );
  }
}
