import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard.dart';
import 'screens/expenses.dart';
import 'screens/savings.dart';
import 'screens/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Simple state management for theme
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fintech App',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // Default, but explicit
        scaffoldBackgroundColor: AppColors.purple50, // Default Light bg
        primaryColor: AppColors.purple600,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.purple600,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.gray900, // Default Dark bg
        primaryColor: AppColors.purple600,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.purple600,
          brightness: Brightness.dark,
        ),
      ),
      home: MainScreen(toggleTheme: _toggleTheme),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const MainScreen({super.key, required this.toggleTheme});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Screens list
    final List<Widget> screens = [
      const DashboardScreen(),
      const ExpensesScreen(),
      // Placeholder for Plus/Central button action (usually a modal, but here just a placeholder tab for index logic)
      const Center(child: Text("Action")), 
      const SavingsScreen(),
      SettingsScreen(onToggleTheme: widget.toggleTheme),
    ];

    return Scaffold(
      // Gradient Background handling for the whole scaffold if needed, but handled in screens usually.
      // However, App.tsx wraps everything in a gradient div. 
      // In Flutter, Scaffold background color is solid. To get the gradient background globally:
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.darkBackground : AppGradients.lightBackground,
        ),
        child: SafeArea(
          bottom: false,
          child: screens[_currentIndex == 2 ? 0 : _currentIndex], // If middle button pressed, don't switch screen or handle differently.
          // Actually, middle button usually opens a modal. For now, let's just not switch tabs if index is 2.
          // Correct logic: Custom nav bar handles interactions.
        ),
      ),
      extendBody: true, // For floating nav bar feel if we used BottomAppBar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray900 : Colors.white,
          border: Border(top: BorderSide(color: isDark ? AppColors.gray800 : AppColors.gray100)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Inicio', isDark),
            _buildNavItem(1, Icons.trending_up, 'Gastos', isDark),
            
            // Middle Floating Button
            GestureDetector(
               onTap: () {
                 // Action for plus button
               },
               child: Container(
                 width: 56,
                 height: 56,
                 margin: const EdgeInsets.only(bottom: 24), // Float up
                 decoration: BoxDecoration(
                   gradient: const LinearGradient(colors: [AppColors.purple600, AppColors.blue600]), // purple-600 to blue-600
                   shape: BoxShape.circle,
                   boxShadow: [
                     BoxShadow(
                       color: AppColors.purple600.withOpacity(0.4),
                       blurRadius: 10,
                       offset: const Offset(0, 5),
                     ),
                   ],
                 ),
                 child: const Icon(Icons.add, color: Colors.white, size: 28),
               ),
            ),

            _buildNavItem(3, Icons.track_changes, 'Ahorros', isDark), // Target icon approx
            _buildNavItem(4, Icons.settings_outlined, 'Ajustes', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    final color = isSelected 
        ? AppColors.purple600 
        : (isDark ? AppColors.gray500 : AppColors.gray400);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
