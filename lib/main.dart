import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'viewmodels/task_viewmodel.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart'; 
import 'services/auth_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();
  runApp(const HabitifyApp());
}

class HabitifyApp extends StatelessWidget {
  const HabitifyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TasksViewModel()),
        Provider(create: (_) => AuthService()),
      ],
      child: Builder(
        builder: (context) {
          final authService = Provider.of<AuthService>(context, listen: false);

          return MaterialApp(
            title: 'BetterMe',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            debugShowCheckedModeBanner: false,
            home: StreamBuilder(
              stream: authService.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData) {
                  return const HomeScreen();
                } else {
                  return const LoginScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
