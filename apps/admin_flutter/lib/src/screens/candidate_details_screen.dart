import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

final candidateDetailProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>((ref, id) async {
  final res = await ref.read(dioProvider).get('/candidates/$id');
  return res.data['data'];
});

class CandidateDetailsScreen extends ConsumerStatefulWidget {
  final String id;
  const CandidateDetailsScreen({super.key, required this.id});

  @override
  ConsumerState<CandidateDetailsScreen> createState() => _CandidateDetailsScreenState();
}

class _CandidateDetailsScreenState extends ConsumerState<CandidateDetailsScreen> {
  bool _isUpdating = false;

  void _updateStatus(String newStatus) async {
    if (newStatus == 'REJECTED' || newStatus == 'HIRED') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Action'),
          content: Text('Are you sure you want to mark this candidate as $newStatus? This is a high-impact action.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Confirm')),
          ],
        )
      );
      if (confirm != true) return;
    }

    setState(() => _isUpdating = true);
    try {
      await ref.read(dioProvider).put('/candidates/${widget.id}/status', data: {'status': newStatus});
      ref.invalidate(candidateDetailProvider(widget.id));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _downloadResume(String storageKey) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Simulating download from GCS: $storageKey')));
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(candidateDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidate Details'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/candidates')),
      ),
      body: asyncData.when(
        data: (app) {
          final candidate = app['candidate'];
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${candidate['firstName']} ${candidate['lastName']}', style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          Text(candidate['email']),
                          Text(candidate['phone'] ?? ''),
                          const Divider(height: 32),
                          const Text('Application Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 8),
                          Text('Position: ${app['position']['title']}'),
                          Text('Reference: ${app['referenceId']}'),
                          Text('Experience: ${app['experienceYears']} Years'),
                          Text('Current Role: ${app['currentRole'] ?? 'N/A'} at ${app['currentCompany'] ?? 'N/A'}'),
                          const Divider(height: 32),
                          const Text('Documents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 8),
                          ...List.from(app['documents'] ?? []).map((doc) => ListTile(
                            leading: const Icon(Icons.insert_drive_file),
                            title: Text(doc['logicalName']),
                            trailing: IconButton(icon: const Icon(Icons.download), onPressed: () => _downloadResume(doc['storageKey'])),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 16),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: app['status'],
                            items: const [
                              DropdownMenuItem(value: 'APPLIED', child: Text('Applied')),
                              DropdownMenuItem(value: 'REVIEWING', child: Text('Reviewing')),
                              DropdownMenuItem(value: 'INTERVIEW', child: Text('Interview')),
                              DropdownMenuItem(value: 'OFFER', child: Text('Offer')),
                              DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                              DropdownMenuItem(value: 'HIRED', child: Text('Hired')),
                            ],
                            onChanged: _isUpdating ? null : (v) => _updateStatus(v!),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
