import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

class CandidateListScreen extends ConsumerStatefulWidget {
  const CandidateListScreen({super.key});

  @override
  ConsumerState<CandidateListScreen> createState() => _CandidateListScreenState();
}

class _CandidateListScreenState extends ConsumerState<CandidateListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _candidates = [];
  List<Map<String, dynamic>> _positions = [];

  String _search = '';
  String _selectedPositionId = 'All Positions';
  String _selectedStatus = 'All Statuses';

  @override
  void initState() {
    super.initState();
    _loadPositionsAndCandidates();
  }

  Future<void> _loadPositionsAndCandidates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(adminApiClientProvider);
      final positions = await client.getPositions();
      final candidates = await client.getCandidates(
        search: _search.isNotEmpty ? _search : null,
        status: _selectedStatus != 'All Statuses' ? _selectedStatus : null,
        positionId: _selectedPositionId != 'All Positions' ? _selectedPositionId : null,
      );

      if (mounted) {
        setState(() {
          _positions = positions;
          _candidates = candidates;
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'HIRED':
      case 'OFFER':
        return Colors.green.shade50;
      case 'INTERVIEW':
        return Colors.purple.shade50;
      case 'SHORTLISTED':
      case 'REVIEWING':
        return Colors.blue.shade50;
      case 'REJECTED':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toUpperCase()) {
      case 'HIRED':
      case 'OFFER':
        return Colors.green.shade800;
      case 'INTERVIEW':
        return Colors.purple.shade800;
      case 'SHORTLISTED':
      case 'REVIEWING':
        return Colors.blue.shade800;
      case 'REJECTED':
        return Colors.red.shade800;
      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    final positionItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: 'All Positions', child: Text('All Positions')),
      ..._positions.map((p) => DropdownMenuItem(
        value: p['id']?.toString() ?? '',
        child: Text(p['title']?.toString() ?? 'Position', overflow: TextOverflow.ellipsis),
      )),
    ];

    final statusOptions = ['All Statuses', 'APPLIED', 'REVIEWING', 'SHORTLISTED', 'INTERVIEW', 'OFFER', 'REJECTED', 'HIRED'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Candidates', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (val) {
                  _search = val.trim();
                  _loadPositionsAndCandidates();
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search candidates by name, position...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                constraints: const BoxConstraints(maxWidth: 200),
              ),
              value: _selectedPositionId,
              items: positionItems,
              onChanged: (v) {
                if (v != null) {
                  setState(() => _selectedPositionId = v);
                  _loadPositionsAndCandidates();
                }
              },
            ),
            const SizedBox(width: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                constraints: const BoxConstraints(maxWidth: 200),
              ),
              value: _selectedStatus,
              items: statusOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _selectedStatus = v);
                  _loadPositionsAndCandidates();
                }
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
                  ElevatedButton(onPressed: _loadPositionsAndCandidates, child: const Text('Retry')),
                ],
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _candidates.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text('No candidates found.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                        dataRowMinHeight: 64,
                        dataRowMaxHeight: 64,
                        columns: const [
                          DataColumn(label: Text('Candidate')),
                          DataColumn(label: Text('Position')),
                          DataColumn(label: Text('Experience')),
                          DataColumn(label: Text('Notice Period')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: _candidates.map((c) {
                          final candId = c['id']?.toString() ?? '';
                          final candName = c['name']?.toString() ??
                              '${c['firstName'] ?? ''} ${c['lastName'] ?? ''}'.trim();
                          final displayName = candName.isNotEmpty ? candName : 'Applicant';
                          final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C';
                          final posTitle = c['position']?.toString() ?? c['positionTitle']?.toString() ?? 'Position';
                          final exp = c['experience']?.toString() ?? c['totalExperience']?.toString() ?? '-';
                          final notice = c['notice']?.toString() ?? c['noticePeriod']?.toString() ?? '-';
                          final status = c['status']?.toString() ?? 'APPLIED';

                          return DataRow(
                            cells: [
                              DataCell(Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.shade50,
                                    child: Text(initial, style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              )),
                              DataCell(Text(posTitle)),
                              DataCell(Text(exp)),
                              DataCell(Text(notice)),
                              DataCell(
                                Chip(
                                  label: Text(status, style: TextStyle(color: _getStatusTextColor(status), fontWeight: FontWeight.w600)),
                                  backgroundColor: _getStatusColor(status),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.blueAccent),
                                  onPressed: () => context.go('/candidates/$candId'),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}
