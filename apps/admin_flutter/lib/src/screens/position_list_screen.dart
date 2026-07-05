import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

final positionsProvider = FutureProvider.autoDispose((ref) async {
  final res = await ref.read(dioProvider).get('/positions');
  return res.data['data'] as List;
});

class PositionListScreen extends ConsumerWidget {
  const PositionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positions = ref.watch(positionsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Positions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/positions/new'),
        child: const Icon(Icons.add),
      ),
      body: positions.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final pos = data[index];
            return ListTile(
              title: Text(pos['title'] ?? 'Untitled'),
              subtitle: Text('${pos['department'] ?? 'No Dept'} • ${pos['status']}'),
              trailing: const Icon(Icons.edit),
              onTap: () => context.go('/positions/${pos['id']}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
