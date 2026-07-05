import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

final feedbackListProvider = FutureProvider.autoDispose((ref) async {
  final res = await ref.read(dioProvider).get('/feedback');
  return res.data['data'] as List;
});

class FeedbackListScreen extends ConsumerStatefulWidget {
  const FeedbackListScreen({super.key});
  @override
  ConsumerState<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends ConsumerState<FeedbackListScreen> {
  String _searchQuery = '';
  
  void _updateFeedback(String id, String status, String priority, String? notes) async {
    try {
      await ref.read(dioProvider).put('/feedback/$id', data: {
        'status': status,
        'priority': priority,
        'internalNotes': notes
      });
      ref.invalidate(feedbackListProvider);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final notesCtrl = TextEditingController(text: item['internalNotes']);
    String currentStatus = item['status'] ?? 'NEW';
    String currentPriority = item['priority'] ?? 'LOW';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Manage Feedback'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item['feedbackText'], style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: currentStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['NEW', 'REVIEWED', 'PLANNED', 'IMPLEMENTED', 'CLOSED'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => currentStatus = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: currentPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: ['LOW', 'MEDIUM', 'HIGH'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => currentPriority = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Internal Notes', border: OutlineInputBorder()),
                  maxLines: 3,
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _updateFeedback(item['id'], currentStatus, currentPriority, notesCtrl.text);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            )
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedbackAsync = ref.watch(feedbackListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Dashboard'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/dashboard')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Search Feedback', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: feedbackAsync.when(
              data: (data) {
                final filtered = data.where((f) => f['feedbackText'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(item['feedbackText']),
                        subtitle: Text('Module: ${item['module']} | Date: ${item['createdAt'].split('T')[0]}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(label: Text(item['status'] ?? 'NEW', style: const TextStyle(fontSize: 12))),
                            const SizedBox(width: 8),
                            Chip(label: Text(item['priority'] ?? 'LOW', style: const TextStyle(fontSize: 12)), backgroundColor: item['priority'] == 'HIGH' ? Colors.red.shade100 : Colors.grey.shade200),
                            IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(item))
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            )
          )
        ],
      ),
    );
  }
}
