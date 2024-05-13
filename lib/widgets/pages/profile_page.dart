import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://img07.rl0.ru/afisha/e1200x1200i/daily.afisha.ru/uploads/images/e/e6/ee61603b83298547cb43d2c70c8af339.jpg'),
            ),
            SizedBox(height: 20),

            Text(
              'Name',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'example@example.com',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // ElevatedButton(
            //   onPressed: () {
            //   },
            //   child: const Text('Edit profile'),
            // ),
          ],
        ),
      ),
    );
  }
}
