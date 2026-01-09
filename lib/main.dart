// lib/main.dart
import 'dart:io'; // Needed to check if we are on Windows
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Windows DB Support
import 'screens/splash_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------------------
  // 👇 WINDOWS SETUP: Initialize Database
  // ------------------------------------------------
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 1. Initialize Timezone
  tz.initializeTimeZones();
  
  // 2. Get Device Timezone (Safely)
  String timeZoneName = 'UTC';
  try {
    timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  } catch (e) {
    // Ignore error
  }
  
  try {
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  // 3. Initialize Notifications (Android Only)
  // We wrap this so it doesn't crash on Windows
  if (Platform.isAndroid) {
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Habit Health Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}