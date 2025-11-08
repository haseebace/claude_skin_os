
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F0),
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await fb.FirebaseAuth.instance.signOut();
                } catch (e) {
                  print('Error signing out: $e');
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
