import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuccessScreen extends StatelessWidget {
  final String? refId;
  const SuccessScreen({super.key, this.refId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            const Text('Application Submitted Successfully!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Your reference ID is: ${refId ?? "Unknown"}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('We will review your application and get back to you soon.'),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: () => context.go('/'), child: const Text('Back to Careers')),
          ],
        ),
      ),
    );
  }
}
