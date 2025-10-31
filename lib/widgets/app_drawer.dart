import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<HabitViewModel>(context);
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'Guest'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: vm.isDarkMode
                    ? [Colors.grey.shade900, Colors.black]
                    : [Colors.indigo, Colors.blue],
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(vm.isDarkMode ? 'Light Mode' : 'Dark Mode'),
            onTap: () {
              vm.toggleTheme();
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await auth.signOut();
              Navigator.pop(context);
            },
          ),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Habitify v1.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
