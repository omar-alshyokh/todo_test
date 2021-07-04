import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morphosis_flutter_demo/data/repo/firebase_manager.dart';
import 'package:morphosis_flutter_demo/ui/my_app.dart';
import 'package:morphosis_flutter_demo/ui/screens/index.dart';
import 'package:morphosis_flutter_demo/ui/widgets/error_widget.dart';
import 'package:uuid/uuid.dart';

import 'di/components/service_locator.dart';

const title = 'Morphosis Demo';
const uuid = Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runZonedGuarded(() {
    runApp(FirebaseApp());
  }, (error, stackTrace) {
    print('runZonedGuarded: Caught error in my root zone.');
  });
}

class FirebaseApp extends StatefulWidget {
  @override
  _FirebaseAppState createState() => _FirebaseAppState();
}

class _FirebaseAppState extends State<FirebaseApp> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    // Wait for Firebase to initialize
    await getIt<FirebaseManager>().initializeFirebase();

    debugPrint("firebase initialized");

    // Pass all uncaught errors to Crashlytics.
    Function originalOnError = FlutterError.onError!;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      // Forward to original handler.
      originalOnError(errorDetails);
    };
  }

  // Define an async function to initialize FlutterFire
  void initialize() async {
    if (_error) {
      setState(() {
        _error = false;
      });
    }

    try {
      await _initializeFlutterFire();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error || !_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        home: Scaffold(
          body: _error
              ? ErrorMessage(
                  message: "Problem initialising the app",
                  buttonTitle: "RETRY",
                  onTap: initialize,
                )
              : Container(),
        ),
      );
    }
    return App();
  }
}

class App extends StatelessWidget {
  ///TODO: Try to implement themeing and use it throughout the app
  /// For reference : https://flutter.dev/docs/cookbook/design/themes
  ///

  ///TODO: Restructure folders pr rearrange folders based on your need.
  ///TODO: Implement state management of your choice.

  @override
  Widget build(BuildContext context) {
    return MyApp();
  }
}
