import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

class PositionListingScreen extends ConsumerStatefulWidget {
  const PositionListingScreen({super.key});

  @override
  ConsumerState<PositionListingScreen> createState() => _PositionListingScreenState();
}

class _PositionListingScreenState extends ConsumerState<PositionListingScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _positions = [];

  String _searchQuery = '';
  String? _selectedDepartment;
  String? _selectedLocation;
  String? _selectedExperience;

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
      final client = ref.read(candidateApiClientProvider);
      final positions = await client.getPublicPositions();
      if (mounted) {
        setState(() {
          _positions = positions;
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

  List<String> get _departments => _positions
      .map((p) => p['department']?.toString() ?? '')
      .where((d) => d.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<String> get _locations => _positions
      .map((p) => p['location']?.toString() ?? '')
      .where((l) => l.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<String> get _experiences => _positions
      .map((p) => p['experience']?.toString() ?? '')
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<Map<String, dynamic>> get _filteredPositions {
    return _positions.where((p) {
      final title = (p['title'] ?? '').toString().toLowerCase();
      final dept = (p['department'] ?? '').toString();
      final loc = (p['location'] ?? '').toString();
      final exp = (p['experience'] ?? '').toString();

      final matchesSearch = _searchQuery.isEmpty || title.contains(_searchQuery.toLowerCase());
      final matchesDept = _selectedDepartment == null || dept == _selectedDepartment;
      final matchesLoc = _selectedLocation == null || loc == _selectedLocation;
      final matchesExp = _selectedExperience == null || exp == _selectedExperience;
      return matchesSearch && matchesDept && matchesLoc && matchesExp;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Open Positions', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search jobs...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('Department', _departments, _selectedDepartment, (v) => setState(() => _selectedDepartment = v))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdown('Location', _locations, _selectedLocation, (v) => setState(() => _selectedLocation = v))),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDropdown('Experience', _experiences, _selectedExperience, (v) => setState(() => _selectedExperience = v))),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(onPressed: _loadPositions, child: const Text('Retry')),
                                ],
                              ),
                            ),
                          )
                        : _filteredPositions.isEmpty
                            ? const Center(child: Text('No positions found.', style: TextStyle(fontSize: 18, color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                                itemCount: _filteredPositions.length,
                                itemBuilder: (context, index) {
                                  final pos = _filteredPositions[index];
                                  final title = pos['title']?.toString() ?? 'Untitled Position';
                                  final department = pos['department']?.toString() ?? 'General';
                                  final location = pos['location']?.toString() ?? 'Remote';
                                  final employmentType = pos['employmentType']?.toString() ?? pos['type']?.toString() ?? 'Full-time';
                                  final experience = pos['experience']?.toString() ?? '1+ Years';
                                  final shortDescription = pos['shortDescription']?.toString() ?? pos['description']?.toString() ?? '';
                                  final posId = pos['id']?.toString() ?? '';

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  title,
                                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Chip(
                                                label: Text(department),
                                                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                                                side: BorderSide.none,
                                              ),
                                            ],
                                          ),
                                           Wrap(
                                             spacing: 16,
                                             runSpacing: 8,
                                             crossAxisAlignment: WrapCrossAlignment.center,
                                             children: [
                                               Row(
                                                 mainAxisSize: MainAxisSize.min,
                                                 children: [
                                                   const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                                   const SizedBox(width: 4),
                                                   Text(location, style: const TextStyle(color: Colors.grey)),
                                                 ],
                                               ),
                                               Row(
                                                 mainAxisSize: MainAxisSize.min,
                                                 children: [
                                                   const Icon(Icons.work_outline, size: 16, color: Colors.grey),
                                                   const SizedBox(width: 4),
                                                   Text(employmentType, style: const TextStyle(color: Colors.grey)),
                                                 ],
                                               ),
                                               Row(
                                                 mainAxisSize: MainAxisSize.min,
                                                 children: [
                                                   const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                                   const SizedBox(width: 4),
                                                   Text(experience, style: const TextStyle(color: Colors.grey)),
                                                 ],
                                               ),
                                               if (pos['immediateJoiner'] == true || pos['immediateJoinerRequired'] == true)
                                                 Container(
                                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                   decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.orange.shade200)),
                                                   child: Text('Immediate Joiner', style: TextStyle(color: Colors.orange.shade900, fontSize: 12, fontWeight: FontWeight.bold)),
                                                 ),
                                             ],
                                           ),
                                           if (pos['skills'] is List && (pos['skills'] as List).isNotEmpty) ...[
                                             const SizedBox(height: 12),
                                             Wrap(
                                               spacing: 6,
                                               runSpacing: 6,
                                               children: (pos['skills'] as List).map((s) => Container(
                                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                 decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.teal.shade200)),
                                                 child: Text(s.toString(), style: TextStyle(color: Colors.teal.shade900, fontSize: 12, fontWeight: FontWeight.w600)),
                                               )).toList(),
                                             ),
                                           ],
                                           if (shortDescription.isNotEmpty) ...[
                                             const SizedBox(height: 16),
                                             Text(shortDescription, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                                           ],
                                          const SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                onPressed: () => context.go('/positions/$posId'),
                                                child: const Text('View Details'),
                                              ),
                                              const SizedBox(width: 16),
                                              ElevatedButton(
                                                onPressed: () => context.go('/positions/$posId/apply'),
                                                child: const Text('Apply Now'),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      hint: Text(hint),
      value: value,
      items: [
        const DropdownMenuItem(value: null, child: Text('All')),
        ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
      ],
      onChanged: onChanged,
    );
  }
}
