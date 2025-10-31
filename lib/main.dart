import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'viewmodels/habit_viewmodel.dart';
import 'views/home_screen.dart';
import 'services/auth_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const HabitifyApp());
}

class HabitifyApp extends StatelessWidget {
  const HabitifyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitViewModel()),
        Provider(create: (_) => AuthService()),
      ],
      child: Builder(builder: (context) {
        final vm = Provider.of<HabitViewModel>(context);
        return MaterialApp(
          title: 'Habitify',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: vm.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      }),
    );
  }
}
