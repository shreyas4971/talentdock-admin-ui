import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';
import 'position_list_screen.dart'; // to get positionsProvider for dropdown

// Provider to hold filter state
class FilterState {
  final String search;
  final String? positionId;
  final String? status;
  FilterState({this.search = '', this.positionId, this.status});
  FilterState copyWith({String? search, String? positionId, String? status, bool clearPosition = false, bool clearStatus = false}) {
    return FilterState(
      search: search ?? this.search,
      positionId: clearPosition ? null : (positionId ?? this.positionId),
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}

final filtersProvider = StateProvider<FilterState>((ref) => FilterState());

final candidatesProvider = FutureProvider.autoDispose((ref) async {
  final filters = ref.watch(filtersProvider);
  final params = <String, dynamic>{};
  if (filters.search.isNotEmpty) params['search'] = filters.search;
  if (filters.positionId != null) params['positionId'] = filters.positionId;
  if (filters.status != null) params['status'] = filters.status;
  
  final res = await ref.read(dioProvider).get('/candidates', queryParameters: params);
  return res.data['data'] as List;
});

class CandidateListScreen extends ConsumerStatefulWidget {
  const CandidateListScreen({super.key});
  @override
  ConsumerState<CandidateListScreen> createState() => _CandidateListScreenState();
}

class _CandidateListScreenState extends ConsumerState<CandidateListScreen> {
  final _searchCtrl = TextEditingController();

  void _exportExcel() {
    final filters = ref.read(filtersProvider);
    final params = <String>[];
    if (filters.search.isNotEmpty) params.add('search=${Uri.encodeComponent(filters.search)}');
    if (filters.positionId != null) params.add('positionId=${filters.positionId}');
    if (filters.status != null) params.add('status=${filters.status}');
    
    final queryStr = params.isNotEmpty ? '?${params.join('&')}' : '';
    // Download via browser navigation
    html.window.open('http://localhost:3000/api/v1/candidates/export$queryStr', '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final candidates = ref.watch(candidatesProvider);
    final positionsAsync = ref.watch(positionsProvider);
    final filters = ref.watch(filtersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidates'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/dashboard')),
        actions: [
          ElevatedButton.icon(
            onPressed: _exportExcel, 
            icon: const Icon(Icons.download),
            label: const Text('Export Excel'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Filters Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(labelText: 'Search (Name, Email, Ref ID)', border: OutlineInputBorder()),
                    onChanged: (val) => ref.read(filtersProvider.notifier).state = filters.copyWith(search: val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: positionsAsync.when(
                    data: (positions) => DropdownButtonFormField<String>(
                      value: filters.positionId,
                      decoration: const InputDecoration(labelText: 'Position', border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Positions')),
                        ...positions.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['title'])))
                      ],
                      onChanged: (val) => ref.read(filtersProvider.notifier).state = filters.copyWith(positionId: val, clearPosition: val == null),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Error loading positions'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: filters.status,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Statuses')),
                      DropdownMenuItem(value: 'APPLIED', child: Text('Applied')),
                      DropdownMenuItem(value: 'REVIEWING', child: Text('Reviewing')),
                      DropdownMenuItem(value: 'INTERVIEW', child: Text('Interview')),
                      DropdownMenuItem(value: 'OFFER', child: Text('Offer')),
                      DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                      DropdownMenuItem(value: 'HIRED', child: Text('Hired')),
                    ],
                    onChanged: (val) => ref.read(filtersProvider.notifier).state = filters.copyWith(status: val, clearStatus: val == null),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    _searchCtrl.clear();
                    ref.read(filtersProvider.notifier).state = FilterState();
                  },
                  child: const Text('Clear Filters'),
                )
              ],
            ),
          ),
          const Divider(),
          // Data Table
          Expanded(
            child: candidates.when(
              data: (data) => SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Ref ID')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Position')),
                      DataColumn(label: Text('Experience')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: data.map((app) {
                      final candidate = app['candidate'];
                      final position = app['position'];
                      return DataRow(cells: [
                        DataCell(Text(app['referenceId'] ?? 'N/A')),
                        DataCell(Text('${candidate['firstName']} ${candidate['lastName']}')),
                        DataCell(Text(position['title'] ?? 'N/A')),
                        DataCell(Text('${app['experienceYears'] ?? 0} Yrs')),
                        DataCell(Text(app['status'] ?? 'APPLIED')),
                        DataCell(
                          IconButton(icon: const Icon(Icons.visibility), onPressed: () => context.go('/candidates/${app['id']}')),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
