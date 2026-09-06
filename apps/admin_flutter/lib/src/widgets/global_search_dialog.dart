import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

class GlobalSearchDialog extends ConsumerStatefulWidget {
  const GlobalSearchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const GlobalSearchDialog(),
    );
  }

  @override
  ConsumerState<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends ConsumerState<GlobalSearchDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _candidates = [];
  List<Map<String, dynamic>> _positions = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = null;
        _candidates = [];
        _positions = [];
        _hasSearched = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(trimmed);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final client = ref.read(adminApiClientProvider);
      final results = await client.search(query);
      if (mounted) {
        final candList = (results['candidates'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        final posList = (results['positions'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        setState(() {
          _candidates = candList;
          _positions = posList;
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
      case 'PUBLISHED':
      case 'HIRED':
      case 'OFFER':
        return Colors.green.shade50;
      case 'INTERVIEW':
        return Colors.purple.shade50;
      case 'SHORTLISTED':
      case 'REVIEWING':
        return Colors.blue.shade50;
      case 'REJECTED':
      case 'ARCHIVED':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toUpperCase()) {
      case 'PUBLISHED':
      case 'HIRED':
      case 'OFFER':
        return Colors.green.shade800;
      case 'INTERVIEW':
        return Colors.purple.shade800;
      case 'SHORTLISTED':
      case 'REVIEWING':
        return Colors.blue.shade800;
      case 'REJECTED':
      case 'ARCHIVED':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResults = _candidates.isNotEmpty || _positions.isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search candidate name, email, phone, ref ID, job title...',
                  hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
                  prefixIcon: const Icon(Icons.search, color: Colors.blueAccent, size: 24),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchCtrl.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const Divider(height: 1),

            // Content Body
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _performSearch(_searchCtrl.text.trim()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : !_hasSearched
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.search, color: Colors.black26, size: 48),
                                    SizedBox(height: 12),
                                    Text(
                                      'Quick Search',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Find candidates by name, email, phone, reference ID,\nor positions by job title and department.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black45, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : !hasResults
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.search_off, color: Colors.black26, size: 48),
                                        SizedBox(height: 12),
                                        Text(
                                          'No results found',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'No candidates or positions matched your query.',
                                          style: TextStyle(color: Colors.black45, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  children: [
                                    // Candidates Section
                                    if (_candidates.isNotEmpty) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                        child: Text(
                                          'CANDIDATES (${_candidates.length})',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      ..._candidates.map((cand) {
                                        final name = cand['name'] ?? 'Candidate';
                                        final posTitle = cand['positionTitle'] ?? '';
                                        final refId = cand['referenceId'] ?? '';
                                        final status = cand['status'] ?? 'APPLIED';
                                        final id = cand['id'] ?? cand['candidateId'];

                                        return Material(
                                          color: Colors.transparent,
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.blue.shade50,
                                              child: Text(
                                                (name.isNotEmpty ? name[0] : 'C').toUpperCase(),
                                                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                            subtitle: Text(
                                              [posTitle, refId].where((s) => s.isNotEmpty).join(' • '),
                                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                                            ),
                                            trailing: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(status),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  color: _getStatusTextColor(status),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              context.go('/candidates/$id');
                                            },
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 16),
                                    ],

                                    // Positions Section
                                    if (_positions.isNotEmpty) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                        child: Text(
                                          'POSITIONS (${_positions.length})',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      ..._positions.map((pos) {
                                        final title = pos['title'] ?? 'Position';
                                        final dept = pos['department'] ?? '';
                                        final loc = pos['location'] ?? '';
                                        final status = pos['status'] ?? 'PUBLISHED';
                                        final id = pos['id'];

                                        return Material(
                                          color: Colors.transparent,
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.teal.shade50,
                                              child: const Icon(Icons.work_outline, color: Colors.teal, size: 20),
                                            ),
                                            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                            subtitle: Text(
                                              [dept, loc].where((s) => s.isNotEmpty).join(' • '),
                                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                                            ),
                                            trailing: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(status),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  color: _getStatusTextColor(status),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              context.go('/positions/$id');
                                            },
                                          ),
                                        );
                                      }),
                                    ],
                                  ],
                                ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
