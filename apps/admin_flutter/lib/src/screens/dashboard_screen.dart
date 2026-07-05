import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

final dashboardProvider = FutureProvider((ref) async {
  final res = await ref.read(dioProvider).get('/dashboard');
  return res.data['data'];
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _showFeedbackDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    bool isSubmitting = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Report Issue / Suggest Improvement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your feedback helps us prioritize the next version.'),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                maxLines: 4,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'What went wrong or what could be better?'),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                if (ctrl.text.isEmpty) return;
                setState(() => isSubmitting = true);
                try {
                  await ref.read(dioProvider).post('/feedback', data: {
                    'module': 'Admin Dashboard',
                    'feedbackText': ctrl.text
                  });
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Thank you for your feedback!')));
                  }
                } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Failed: $e')));
                } finally {
                  if (ctx.mounted) setState(() => isSubmitting = false);
                }
              },
              child: isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit'),
            )
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.feedback, color: Colors.white),
            tooltip: 'Provide Feedback',
            onPressed: () => _showFeedbackDialog(context, ref),
          ),
          TextButton(
            onPressed: () => context.go('/feedback'), 
            child: const Text('Feedback Board', style: TextStyle(color: Colors.white))
          ),
          TextButton(
            onPressed: () => context.go('/candidates'), 
            child: const Text('Candidates', style: TextStyle(color: Colors.white))
          ),
          TextButton(
            onPressed: () => context.go('/positions'), 
            child: const Text('Positions', style: TextStyle(color: Colors.white))
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              context.go('/login');
            },
          )
        ],
      ),
      body: counts.when(
        data: (data) {
          final analytics = data['analytics'] ?? {};
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildStatCard('Open Positions', data['openPositions']),
                      _buildStatCard('Total Applications', data['totalApplications']),
                      _buildStatCard('Apps Today', data['applicationsToday']),
                      _buildStatCard('Shortlisted', data['shortlisted']),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('Usage Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildStatCard('Positions Created', analytics['positionsCreated'], Colors.indigo),
                      _buildStatCard('Applications Submitted', analytics['applicationsSubmitted'], Colors.purple),
                      _buildStatCard('Status Changes', analytics['statusChanges'], Colors.teal),
                      _buildStatCard('Excel Exports', analytics['excelExports'], Colors.green),
                      _buildStatCard('Feedback Provided', analytics['feedbacksSubmitted'], Colors.deepOrange),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatCard(String title, dynamic count, [Color? color]) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: color ?? Colors.black54)),
            const SizedBox(height: 8),
            Text('${count ?? 0}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
