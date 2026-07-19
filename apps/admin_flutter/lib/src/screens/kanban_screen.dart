import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_client.dart';

final kanbanPositionsProvider = FutureProvider.autoDispose((ref) async {
  final res = await ref.read(dioProvider).get('/positions');
  return res.data['data'] as List;
});

class KanbanScreen extends ConsumerStatefulWidget {
  const KanbanScreen({super.key});
  @override
  ConsumerState<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends ConsumerState<KanbanScreen> {
  bool _isLoading = true;
  List<dynamic> _candidates = [];
  
  String _searchQuery = '';
  String? _selectedPositionId;
  String? _selectedTag;
  Set<String> _collapsedColumns = {};
  Set<String> _availableTags = {};
  final Set<String> _updatingIds = {};

  final List<String> columns = ['APPLIED', 'REVIEWING', 'INTERVIEW', 'OFFER', 'REJECTED', 'HIRED'];

  @override
  void initState() {
    super.initState();
    _loadPrefsAndData();
  }

  Future<void> _loadPrefsAndData() async {
    final prefs = await SharedPreferences.getInstance();
    _searchQuery = prefs.getString('kb_search') ?? '';
    _selectedPositionId = prefs.getString('kb_pos');
    _selectedTag = prefs.getString('kb_tag');
    _collapsedColumns = (prefs.getStringList('kb_collapsed') ?? []).toSet();
    
    await _fetchCandidates();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kb_search', _searchQuery);
    if (_selectedPositionId != null) await prefs.setString('kb_pos', _selectedPositionId!);
    else await prefs.remove('kb_pos');
    
    if (_selectedTag != null) await prefs.setString('kb_tag', _selectedTag!);
    else await prefs.remove('kb_tag');
    
    await prefs.setStringList('kb_collapsed', _collapsedColumns.toList());
  }

  Future<void> _fetchCandidates() async {
    setState(() => _isLoading = true);
    try {
      final res = await ref.read(dioProvider).get('/candidates');
      _candidates = res.data['data'] as List;
      
      // Extract unique tags
      _availableTags.clear();
      for (var app in _candidates) {
        final tags = app['candidate']['tags'] ?? [];
        for (var tag in tags) {
          _availableTags.add(tag);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateStatus(String applicationId, String oldStatus, String newStatus) async {
    if (oldStatus == newStatus) return;

    final index = _candidates.indexWhere((c) => c['id'] == applicationId);
    if (index == -1) return;

    setState(() {
      _candidates[index]['status'] = newStatus;
      _updatingIds.add(applicationId);
    });

    try {
      await ref.read(dioProvider).put('/candidates/$applicationId/status', data: {'status': newStatus});
    } catch (e) {
      if (mounted) {
        setState(() {
          _candidates[index]['status'] = oldStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update status. Rolled back.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingIds.remove(applicationId);
        });
      }
    }
  }

  void _toggleColumn(String col) {
    setState(() {
      if (_collapsedColumns.contains(col)) {
        _collapsedColumns.remove(col);
      } else {
        _collapsedColumns.add(col);
      }
    });
    _savePrefs();
  }

  Color _getColumnColor(String col) {
    switch (col) {
      case 'APPLIED': return Colors.grey;
      case 'REVIEWING': return Colors.blue;
      case 'INTERVIEW': return Colors.purple;
      case 'OFFER': return Colors.orange;
      case 'REJECTED': return Colors.red;
      case 'HIRED': return Colors.green;
      default: return Colors.grey;
    }
  }

  List<dynamic> _getFilteredCandidates() {
    return _candidates.where((app) {
      final c = app['candidate'];
      final p = app['position'];
      
      // Position filter
      if (_selectedPositionId != null && _selectedPositionId != 'ALL' && app['positionId'] != _selectedPositionId) return false;
      
      // Tag filter
      if (_selectedTag != null && _selectedTag != 'ALL') {
        final tags = List<String>.from(c['tags'] ?? []);
        if (!tags.contains(_selectedTag)) return false;
      }
      
      // Search
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final name = '${c['firstName']} ${c['lastName']}'.toLowerCase();
        final posTitle = p['title'].toString().toLowerCase();
        if (!name.contains(q) && !posTitle.contains(q)) return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final positionsAsync = ref.watch(kanbanPositionsProvider);
    final filtered = _getFilteredCandidates();
    
    // Grouping
    final grouped = <String, List<dynamic>>{};
    for (var c in columns) {
      grouped[c] = filtered.where((x) => x['status'] == c).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanban Pipeline'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/dashboard')),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchCandidates),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Search candidates...', border: OutlineInputBorder()),
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                      _savePrefs();
                    },
                    controller: TextEditingController(text: _searchQuery)..selection = TextSelection.collapsed(offset: _searchQuery.length),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: positionsAsync.when(
                    data: (positions) => DropdownButtonFormField<String>(
                      value: _selectedPositionId,
                      decoration: const InputDecoration(labelText: 'Position', border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Positions')),
                        ...positions.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['title'])))
                      ],
                      onChanged: (val) {
                        setState(() => _selectedPositionId = val);
                        _savePrefs();
                      },
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Error loading positions'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTag,
                    decoration: const InputDecoration(labelText: 'Tag', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Tags')),
                      ..._availableTags.map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    ],
                    onChanged: (val) {
                      setState(() => _selectedTag = val);
                      _savePrefs();
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Kanban Board
          Expanded(
            child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: columns.map((col) {
                    final isCollapsed = _collapsedColumns.contains(col);
                    final colCandidates = grouped[col]!;
                    final colColor = _getColumnColor(col);

                    if (isCollapsed) {
                      return InkWell(
                        onTap: () => _toggleColumn(col),
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: colColor.withOpacity(0.2),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8))
                                ),
                                child: Center(child: Icon(Icons.expand_more, color: colColor)),
                              ),
                              const SizedBox(height: 16),
                              RotatedBox(
                                quarterTurns: 1,
                                child: Text('$col (${colCandidates.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              )
                            ],
                          ),
                        ),
                      );
                    }

                    return Container(
                      width: 320,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colColor.withOpacity(0.2),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 12, height: 12, decoration: BoxDecoration(color: colColor, shape: BoxShape.circle)),
                                    const SizedBox(width: 8),
                                    Text('$col', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                                      child: Text('${colCandidates.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                                IconButton(icon: const Icon(Icons.compress), onPressed: () => _toggleColumn(col))
                              ],
                            ),
                          ),
                          Expanded(
                            child: DragTarget<String>(
                              onWillAcceptWithDetails: (details) => true,
                              onAcceptWithDetails: (details) {
                                final dataParts = details.data.split('|');
                                if (dataParts.length == 2) {
                                  _updateStatus(dataParts[0], dataParts[1], col);
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                return ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: colCandidates.length,
                                  itemBuilder: (ctx, i) {
                                    final item = colCandidates[i];
                                    final dragData = '${item['id']}|${item['status']}';
                                    return Draggable<String>(
                                      data: dragData,
                                      feedback: Material(
                                        elevation: 8,
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          width: 300,
                                          child: _buildCard(item, isDragging: true),
                                        ),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.3,
                                        child: _buildCard(item),
                                      ),
                                      child: _buildCard(item),
                                    );
                                  },
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          )
        ],
      ),
    );
  }

  Widget _buildCard(dynamic item, {bool isDragging = false}) {
    final c = item['candidate'];
    final pos = item['position'];
    final tags = List<String>.from(c['tags'] ?? []);
    final updated = DateTime.parse(item['updatedAt']).toLocal();
    final timeStr = '${updated.month}/${updated.day} ${updated.hour}:${updated.minute.toString().padLeft(2,'0')}';
    final isUpdating = _updatingIds.contains(item['id']);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isDragging ? 8 : 1,
      child: InkWell(
        onTap: () => context.go('/candidates/${item['id']}'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: Text('${c['firstName']} ${c['lastName']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                        if (isUpdating) const Padding(padding: EdgeInsets.only(left: 8), child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))),
                      ],
                    ),
                  ),
                  Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Text(pos['title'], style: const TextStyle(color: Colors.grey)),
              if (item['experienceYears'] != null) Text('Exp: ${item['experienceYears']} Yrs', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: tags.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(4)),
                    child: Text(t, style: const TextStyle(fontSize: 10)),
                  )).toList(),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
