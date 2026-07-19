import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../mock_data.dart';

class PositionListingScreen extends StatefulWidget {
  const PositionListingScreen({super.key});

  @override
  State<PositionListingScreen> createState() => _PositionListingScreenState();
}

class _PositionListingScreenState extends State<PositionListingScreen> {
  String _searchQuery = '';
  String? _selectedDepartment;
  String? _selectedLocation;
  String? _selectedExperience;

  List<String> get _departments => mockPositions.map((p) => p['department'] as String).toSet().toList()..sort();
  List<String> get _locations => mockPositions.map((p) => p['location'] as String).toSet().toList()..sort();
  List<String> get _experiences => mockPositions.map((p) => p['experience'] as String).toSet().toList()..sort();

  List<Map<String, dynamic>> get _filteredPositions {
    return mockPositions.where((p) {
      final matchesSearch = p['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDept = _selectedDepartment == null || p['department'] == _selectedDepartment;
      final matchesLoc = _selectedLocation == null || p['location'] == _selectedLocation;
      final matchesExp = _selectedExperience == null || p['experience'] == _selectedExperience;
      return matchesSearch && matchesDept && matchesLoc && matchesExp;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPositions;
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
                      onChanged: (val) => setState(() => _searchQuery = val),
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
                child: filtered.isEmpty
                    ? const Center(child: Text('No positions found.', style: TextStyle(fontSize: 18, color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final pos = filtered[index];
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
                                      Text(pos['title'], style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                      Chip(
                                        label: Text(pos['department']),
                                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                                        side: BorderSide.none,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(pos['location'], style: const TextStyle(color: Colors.grey)),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.work_outline, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(pos['employmentType'], style: const TextStyle(color: Colors.grey)),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(pos['experience'], style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(pos['shortDescription'], style: const TextStyle(fontSize: 15, color: Colors.black87)),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => context.go('/positions/${pos['id']}'),
                                        child: const Text('View Details'),
                                      ),
                                      const SizedBox(width: 16),
                                      ElevatedButton(
                                        onPressed: () => context.go('/positions/${pos['id']}/apply'),
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
