import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/routing/app_router.dart';
import 'firebase_options.dart';
import 'dart:async';

Future<void> main() async {
  // Setup global error handlers to prevent crashes and keep DevTools connected
  // These must be set up BEFORE any async operations or zone creation
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('[FlutterError] ${details.exception}');
    print('[FlutterError] Stack: ${details.stack}');
  };
  
  // Handle async errors (Future.catchError, etc.)
  PlatformDispatcher.instance.onError = (error, stack) {
    print('[PlatformError] $error');
    print('[PlatformError] Stack: $stack');
    return true; // Prevents app from crashing
  };
  
  // Wrap everything in a zone to catch all errors
  // This ensures ensureInitialized and runApp are in the same zone
  runZonedGuarded(() async {
    // Initialize Flutter bindings inside the zone
    WidgetsFlutterBinding.ensureInitialized();
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(const ProviderScope(child: MainApp()));
  }, (error, stack) {
    print('[ZoneError] $error');
    print('[ZoneError] Stack: $stack');
  });
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
    );
  }
}
