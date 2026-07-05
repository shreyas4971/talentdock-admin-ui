import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

final dashboardProvider = FutureProvider((ref) async {
  final res = await ref.read(dioProvider).get('/dashboard/counts');
  return res.data['data'];
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          TextButton(
            onPressed: () => context.go('/candidates'), 
            child: const Text('Candidates', style: TextStyle(color: Colors.white))
          ),
          TextButton(
            onPressed: () => context.go('/positions'), 
            child: const Text('Positions', style: TextStyle(color: Colors.white))
          ),
        ],
      ),
      body: counts.when(
        data: (data) => Padding(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard('Positions', data['positions']),
              const SizedBox(width: 16),
              _buildStatCard('Candidates', data['candidates']),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatCard(String title, dynamic count) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Text('$count', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
