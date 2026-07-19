import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 64.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.work_outline, size: 80, color: Colors.blueAccent),
                      const SizedBox(height: 32),
                      const Text('Welcome back to TalentDock', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      const Text('Sign in to manage your recruitment pipeline', style: TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center),
                      const SizedBox(height: 48),
                      const TextField(decoration: InputDecoration(labelText: 'Email Address')),
                      const SizedBox(height: 24),
                      const TextField(decoration: InputDecoration(labelText: 'Password'), obscureText: true),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
