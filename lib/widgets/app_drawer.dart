import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_viewmodel.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TasksViewModel>(context);
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? 'Guest'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.transparent],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette, color: Colors.white),
              title: const Text(
                'Appearance',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Switch(
                value: vm.themeVariant == 1,
                onChanged: (value) {
                  vm.toggleThemeVariant();
                },
                activeColor: Colors.greenAccent,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final auth = Provider.of<AuthService>(context, listen: false);
                await auth.signOut();
                ;
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'BetterMe v1.0',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
