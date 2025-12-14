import 'package:final_project_flutter/widgets/pages/profile_page.dart';
import 'package:final_project_flutter/widgets/pages/registration_page.dart';
import 'package:final_project_flutter/widgets/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:final_project_flutter/widgets/auth_provider.dart';
import 'package:final_project_flutter/widgets/pages/login_page.dart';
import 'package:final_project_flutter/widgets/pages/menus_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'FoodWeek'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                  ),
                  child: Text(
                    'FoodWeek',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                if (authProvider.isAuthenticated) ...[
                  ListTile(
                    title: const Text('My profile'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Menus'),
                    onTap: () {
                      if (authProvider.isAuthenticated) {
                        // Navigate to menus page if authenticated
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MenusPage()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please log in to access menus.'),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Logout'),
                    onTap: () async {
                      String? token =
                          Provider.of<AuthProvider>(context, listen: false)
                              .token;

                      final response = await http.post(
                        Uri.parse('http://10.0.2.2:8000/api/auth/logout'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                          'Authorization': 'Bearer $token',
                        },
                      );

                      if (response.statusCode == 200) {
                        Provider.of<AuthProvider>(context, listen: false)
                            .setToken(null);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      } else {
                        print('Failed to logout: ${response.statusCode}');
                      }
                    },
                  ),
                ] else ...[
                  ListTile(
                    title: const Text('Registration'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrationPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                      title: const Text('Login'),
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      }),
                ],
              ],
            ),
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text(
                    'Welcome to your personal menu-creator ;)',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
