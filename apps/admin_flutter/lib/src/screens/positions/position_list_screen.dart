import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api_client.dart';

class PositionListScreen extends ConsumerStatefulWidget {
  const PositionListScreen({super.key});

  @override
  ConsumerState<PositionListScreen> createState() => _PositionListScreenState();
}

class _PositionListScreenState extends ConsumerState<PositionListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _allPositions = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(adminApiClientProvider);
      final positions = await client.getPositions();
      if (mounted) {
        setState(() {
          _allPositions = positions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = getFriendlyErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleMenuAction(String action, Map<String, dynamic> pos) async {
    final posId = pos['id']?.toString() ?? '';
    final client = ref.read(adminApiClientProvider);

    if (action == 'view') {
      context.go('/candidates');
    } else if (action == 'edit') {
      context.go('/positions/$posId');
    } else if (action == 'dup') {
      try {
        final dupData = Map<String, dynamic>.from(pos);
        dupData.remove('id');
        dupData.remove('applications');
        dupData.remove('applicationCount');
        dupData.remove('createdAt');
        dupData.remove('updatedAt');
        dupData['title'] = '${pos['title'] ?? 'Position'} (Copy)';
        dupData['status'] = 'DRAFT';
        await client.createPosition(dupData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Position duplicated successfully as Draft')),
          );
        }
        await _loadPositions();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to duplicate: ${getFriendlyErrorMessage(e)}')),
          );
        }
      }
    } else if (action == 'archive') {
      try {
        await client.updatePosition(posId, {'status': 'ARCHIVED'});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Position archived successfully')),
          );
        }
        await _loadPositions();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to archive: ${getFriendlyErrorMessage(e)}')),
          );
        }
      }
    } else if (action == 'delete') {
      try {
        await client.deletePosition(posId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Position removed successfully')),
          );
        }
        await _loadPositions();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove: ${getFriendlyErrorMessage(e)}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPositions = _allPositions.where((pos) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final title = (pos['title'] ?? '').toString().toLowerCase();
      final dept = (pos['department'] ?? '').toString().toLowerCase();
      final loc = (pos['location'] ?? '').toString().toLowerCase();
      final type = (pos['type'] ?? pos['employmentType'] ?? '').toString().toLowerCase();
      return title.contains(query) || dept.contains(query) || loc.contains(query) || type.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Positions', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () => context.go('/positions/new'),
              icon: const Icon(Icons.add),
              label: const Text('New Position'),
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search positions...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filter dialog opened')));
              },
            ),
          ],
        ),
        const SizedBox(height: 32),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_errorMessage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadPositions, child: const Text('Retry')),
                ],
              ),
            ),
          )
        else if (filteredPositions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Text(
                _allPositions.isEmpty ? 'No positions created yet. Click "New Position" to start.' : 'No matching positions found.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredPositions.length,
            itemBuilder: (context, index) {
              final pos = filteredPositions[index];
              final status = (pos['status'] ?? 'DRAFT').toString();
              final isPublished = status.toUpperCase() == 'PUBLISHED';
              final appCount = pos['applications'] ?? pos['applicationCount'] ?? 0;
              final dept = pos['department']?.toString() ?? 'Engineering';
              final location = pos['location']?.toString() ?? 'Remote';
              final empType = pos['type']?.toString() ?? pos['employmentType']?.toString() ?? 'Full-time';
              final minExp = pos['minExperience'] ?? pos['minExp'] ?? 0;
              final maxExp = pos['maxExperience'] ?? pos['maxExp'] ?? 5;
              final expDisplay = pos['experience']?.toString() ?? '$minExp-$maxExp yrs';

              return Card(
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pos['title']?.toString() ?? 'Untitled Position', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text('$dept • $location', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                                Text(empType, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                                Text(expDisplay, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Chip(
                            label: Text(isPublished ? 'Published' : status),
                            backgroundColor: isPublished ? Colors.green.shade50 : Colors.grey.shade100,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          const SizedBox(height: 8),
                          Text('$appCount Applications', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                        ],
                      ),
                      const SizedBox(width: 24),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.black54),
                        onSelected: (val) => _handleMenuAction(val, pos),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'view', child: Text('View Candidates')),
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'dup', child: Text('Duplicate')),
                          const PopupMenuItem(value: 'archive', child: Text('Archive')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          )
      ],
    );
  }
}
