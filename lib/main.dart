import 'package:flutter/material.dart';
import 'app/theme.dart';
import 'core/constants/app_strings.dart';
import 'features/home/home_screen_new.dart';
import 'screens/seizure_log_screen.dart';
import 'screens/insights_screen.dart';
import 'features/medications/medications_screen_new.dart';
import 'features/relaxation/relaxation_screen_new.dart';
import 'shared/widgets/app_bottom_nav_bar.dart';
import 'shared/widgets/floating_emergency_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenNew(),
    const RelaxationScreenNew(),
    const MedicationsScreenNew(),
    const InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingEmergencyButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SeizureLogScreen()),
          );
        },
      ),
    );
  }
}