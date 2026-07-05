import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

final publicPositionDetailProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>((ref, id) async {
  final res = await ref.read(dioProvider).get('/positions/$id');
  return res.data['data'];
});

class PositionDetailsScreen extends ConsumerWidget {
  final String id;
  const PositionDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(publicPositionDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      body: asyncData.when(
        data: (pos) => Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pos['title'], style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('${pos['department'] ?? 'General'} • ${pos['location'] ?? 'Remote'}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text(pos['description'] ?? 'No description provided.'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/positions/$id/apply'),
                child: const Text('Apply Now'),
              )
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
