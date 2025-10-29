import 'package:flutter/material.dart';
import 'package:uts_naufal/pages/dashboard_page.dart';
import 'package:uts_naufal/pages/mahasiswa_page.dart';
import 'package:uts_naufal/pages/jadwal_page.dart';
import 'package:uts_naufal/login.dart';

class NavigationDrawerWidget extends StatelessWidget {
  final Map<String, dynamic> user;
  const NavigationDrawerWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/appImages/logo.png',
                  width: 50, // ukuran bisa disesuaikan
                  height: 50,
                ),
                const SizedBox(height: 16),
                Text(
                  'Selamat datang ${user["username"]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(
              context, Icons.home, 'Dashboard', DashboardPage(user: user)),
          if (user['isAdmin'])
            _drawerItem(
              context,
              Icons.person,
              'Data Mahasiswa',
              MahasiswaPage(user: user),
            ),
          _drawerItem(
              context, Icons.schedule, 'Jadwal Kuliah', JadwalPage(user: user)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}
