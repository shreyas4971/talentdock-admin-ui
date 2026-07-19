import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

final templatesProvider = FutureProvider.autoDispose((ref) async {
  final res = await ref.read(dioProvider).get('/templates');
  return res.data['data'] as List;
});

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  void _showTemplateDialog(BuildContext context, WidgetRef ref, [Map? template]) {
    final nameCtrl = TextEditingController(text: template?['name'] ?? '');
    final subjectCtrl = TextEditingController(text: template?['subject'] ?? '');
    final bodyCtrl = TextEditingController(text: template?['body'] ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(template == null ? 'New Template' : 'Edit Template'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (template == null) TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g. Reject, Offer)')),
                const SizedBox(height: 16),
                TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
                const SizedBox(height: 16),
                TextField(controller: bodyCtrl, decoration: const InputDecoration(labelText: 'Body'), maxLines: 5),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                setState(() => isSaving = true);
                try {
                  if (template == null) {
                    await ref.read(dioProvider).post('/templates', data: {
                      'name': nameCtrl.text,
                      'subject': subjectCtrl.text,
                      'body': bodyCtrl.text
                    });
                  } else {
                    await ref.read(dioProvider).put('/templates/${template['id']}', data: {
                      'subject': subjectCtrl.text,
                      'body': bodyCtrl.text
                    });
                  }
                  ref.invalidate(templatesProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(getFriendlyErrorMessage(e))));
                } finally {
                  if (ctx.mounted) setState(() => isSaving = false);
                }
              },
              child: isSaving ? const CircularProgressIndicator() : const Text('Save'),
            )
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Templates'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/dashboard')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTemplateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: templates.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (ctx, i) {
            final t = data[i];
            return ListTile(
              title: Text(t['name']),
              subtitle: Text(t['subject']),
              trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showTemplateDialog(context, ref, t)),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
