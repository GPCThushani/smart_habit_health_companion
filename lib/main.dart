// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'screens/splash_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize timezone package
  tz.initializeTimeZones();

  // Get the device's IANA timezone name (e.g. "Asia/Colombo")
  String timeZoneName;
  try {
    timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  } catch (e) {
    // fallback to UTC (or a specific zone). For development you can set 'UTC' or 'Asia/Colombo'
    timeZoneName = 'UTC';
  }

  try {
    final tz.Location loc = tz.getLocation(timeZoneName);
    tz.setLocalLocation(loc);
  } catch (e) {
    // If the device tz isn't available in tz database, fallback to UTC
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Habit Health Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SplashScreen(),
    );
  }
}
