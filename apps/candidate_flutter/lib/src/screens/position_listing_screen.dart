import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

final publicPositionsProvider = FutureProvider.autoDispose((ref) async {
  final res = await ref.read(dioProvider).get('/positions/public');
  return res.data['data'] as List;
});

class PositionListingScreen extends ConsumerWidget {
  const PositionListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positions = ref.watch(publicPositionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('TalentOS Careers')),
      body: positions.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final pos = data[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(pos['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${pos['department'] ?? 'General'} • ${pos['location'] ?? 'Remote'}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go('/positions/${pos['id']}'),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
