import 'package:flutter/material.dart';

import '../../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _changeTheme(context, ThemeData.light());
              },
              child: const Text('Light Theme'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _changeTheme(context, ThemeData.dark());
              },
              child: const Text('Dark Theme'),
            ),
          ],
        ),
      ),
    );
  }

  void _changeTheme(BuildContext context, ThemeData theme) {
    final newApp = MaterialApp(
      title: 'FoodWeek',
      theme: theme,
      home: const MyHomePage(title: 'FoodWeek'),
    );

    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => newApp),
    );
  }
}
