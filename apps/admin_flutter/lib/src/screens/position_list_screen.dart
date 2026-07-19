import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

final positionsProvider = FutureProvider.autoDispose((ref) async {
  final res = await ref.read(dioProvider).get('/positions');
  return res.data['data'] as List;
});

class PositionListScreen extends ConsumerStatefulWidget {
  const PositionListScreen({super.key});
  @override
  ConsumerState<PositionListScreen> createState() => _PositionListScreenState();
}

class _PositionListScreenState extends ConsumerState<PositionListScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final positions = ref.watch(positionsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Positions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          Row(
            children: [
              const Text('Show Archived'),
              Switch(
                value: _showArchived,
                onChanged: (val) => setState(() => _showArchived = val),
              )
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/positions/new'),
        child: const Icon(Icons.add),
      ),
      body: positions.when(
        data: (data) {
          final filtered = data.where((p) => _showArchived || p['status'] != 'ARCHIVED').toList();
          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final pos = filtered[index];
              final isArchived = pos['status'] == 'ARCHIVED';
              return ListTile(
                tileColor: isArchived ? Colors.grey.withOpacity(0.2) : null,
                title: Text(pos['title'] ?? 'Untitled', style: TextStyle(color: isArchived ? Colors.grey : null)),
                subtitle: Text('${pos['department'] ?? 'No Dept'} • ${pos['status']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Duplicate Position',
                      onPressed: () async {
                        try {
                          await ref.read(dioProvider).post('/positions/${pos['id']}/duplicate');
                          ref.invalidate(positionsProvider);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getFriendlyErrorMessage(e))));
                        }
                      },
                    ),
                    const Icon(Icons.edit),
                  ],
                ),
                onTap: () => context.go('/positions/${pos['id']}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
