import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dine/core/router.dart';
import 'package:dine/core/theme.dart';
import 'package:dine/core/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dine/core/services/realtime_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  // Initialize logger service
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  logger.initialize();

  await Supabase.initialize(
    url: 'https://fdbkqacscdgpvinrkxxy.supabase.co',
    anonKey: 'sb_publishable_91MYgEDzYRAtkPnAIck73w_Z05MIuq7',
  );

  // Initialize real-time service after Supabase
  await realtimeService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FlutterNativeSplash.remove();
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      title: 'Dine',
      theme: ref.read(themeProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
