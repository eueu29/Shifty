import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/duty_repository.dart';
import 'features/alarm/notification_service.dart';
import 'providers/shift_providers.dart';
import 'screens/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize(navigatorKey: navigatorKey);

  final repository = DutyRepository();
  await repository.init();
  final loaded = await repository.loadAll();

  runApp(
    ProviderScope(
      overrides: [
        dutyRepositoryProvider.overrideWithValue(repository),
        initialDutyEntriesProvider.overrideWithValue(loaded),
      ],
      child: const ShiftyApp(),
    ),
  );
}

class ShiftyApp extends StatelessWidget {
  const ShiftyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Shifty',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
