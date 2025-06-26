import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'screens/relative/chat.dart';
import 'viewmodels/appointment_viewmodel.dart';
import 'screens/home/homepage_screen.dart' as home_page;
import 'screens/home/nearby_hospitals_screen.dart';
import 'screens/home/old_homepage_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/signup_screen.dart';
import 'screens/profile/profile_screen.dart' as profile_page;
import 'screens/profile/profile_edit_screen.dart';
import 'shared/splash_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: '...',
        authDomain: '...',
        databaseURL: '...',
        projectId: '...',
        storageBucket: '...',
        messagingSenderId: '...',
        appId: '...',
        measurementId: '...',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kuala_Lumpur'));

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidInit),
  );
  const channel = AndroidNotificationChannel(
    'appt_channel',
    'Appointment Reminders',
    description: 'Channel for appointment notifications',
    importance: Importance.high,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppointmentViewModel(flutterLocalNotificationsPlugin),
      child: const CarePlusApp(),
    ),
  );
}

class CarePlusApp extends StatelessWidget {
  const CarePlusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Care Plus | Senior Health Monitor',
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Roboto'),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.loading,
      routes: {
        AppRoutes.signup: (c) => SignUpScreen(),
        AppRoutes.login: (c) => const LoginScreen(),
        AppRoutes.main: (c) => const MainScaffold(),
        AppRoutes.profile: (c) => const profile_page.ProfileScreen(),
        AppRoutes.loading:
            (c) => SplashScreen(
              onFinished: () {
                Navigator.of(c).pushReplacementNamed(AppRoutes.main);
              },
            ),
        AppRoutes.contactRelatives:
            (c) =>
                const ChatPage(name: 'son', imagePath: 'assets/images/man.png'),
        AppRoutes.profileEdit: (c) {
          final args =
              ModalRoute.of(c)?.settings.arguments as Map<String, dynamic>?;
          return ProfileEditScreen(
            isGuardian: args?['isGuardian'] as bool? ?? false,
          );
        },
      },
      onUnknownRoute:
          (_) => MaterialPageRoute(
            builder:
                (_) => const Scaffold(
                  body: Center(child: Text("404 - Page Not Found")),
                ),
          ),
    );
  }
}

class AppRoutes {
  static const signup = '/signup';
  static const login = '/login';
  static const main = '/main';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const loading = '/loading';
  static const contactRelatives = '/contact-relatives';
}

/// MainScaffold 放在 main.dart 中或单独文件
class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 2;

  final List<Widget> _pages = [
    NearbyHospitalsScreen(),
    Center(child: Icon(Icons.search)),
    home_page.HomepageScreen(),
    const ChatPage(name: 'son', imagePath: 'assets/images/man.png'),
    OldHomepageScreen(),
  ];

  void _onTap(int idx) => setState(() => _currentIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Nearby',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
