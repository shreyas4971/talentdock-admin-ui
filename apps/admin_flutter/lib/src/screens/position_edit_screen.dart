import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

final positionDetailProvider = FutureProvider.family.autoDispose<Map<String, dynamic>?, String?>((ref, id) async {
  if (id == null) return null;
  final res = await ref.read(dioProvider).get('/positions/$id');
  return res.data['data'];
});

class PositionEditScreen extends ConsumerStatefulWidget {
  final String? id;
  const PositionEditScreen({super.key, this.id});

  @override
  ConsumerState<PositionEditScreen> createState() => _PositionEditScreenState();
}

class _PositionEditScreenState extends ConsumerState<PositionEditScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  String _status = 'DRAFT';
  bool _isSaving = false;

  void _save() async {
    setState(() => _isSaving = true);
    try {
      final dio = ref.read(dioProvider);
      final data = {
        'title': _titleCtrl.text,
        'description': _descCtrl.text,
        'department': _deptCtrl.text,
        'status': _status,
      };
      
      if (widget.id == null) {
        await dio.post('/positions', data: data);
      } else {
        await dio.put('/positions/${widget.id}', data: data);
      }
      
      if (mounted) context.go('/positions');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getFriendlyErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(positionDetailProvider(widget.id));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'New Position' : 'Edit Position'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/positions')),
      ),
      body: asyncData.when(
        data: (data) {
          if (data != null && _titleCtrl.text.isEmpty) {
            _titleCtrl.text = data['title'] ?? '';
            _descCtrl.text = data['description'] ?? '';
            _deptCtrl.text = data['department'] ?? '';
            _status = data['status'] ?? 'DRAFT';
          }
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                    const SizedBox(height: 16),
                    TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                    const SizedBox(height: 16),
                    TextField(controller: _deptCtrl, decoration: const InputDecoration(labelText: 'Department')),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
                        DropdownMenuItem(value: 'OPEN', child: Text('Open')),
                        DropdownMenuItem(value: 'CLOSED', child: Text('Closed')),
                        DropdownMenuItem(value: 'ARCHIVED', child: Text('Archived')),
                      ],
                      onChanged: (val) => setState(() => _status = val!),
                    ),
                    const SizedBox(height: 32),
                    _isSaving
                      ? const CircularProgressIndicator()
                      : ElevatedButton(onPressed: _save, child: const Text('Save Position')),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
