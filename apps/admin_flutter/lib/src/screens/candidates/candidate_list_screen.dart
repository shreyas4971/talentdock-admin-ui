
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/page_container.dart';
import '../../mock_data.dart';

class CandidateListScreen extends StatelessWidget {
  const CandidateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Candidates', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search by Name, Email, Phone, Application ID...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(icon: const Icon(Icons.filter_list), label: const Text('Filters'), onPressed: (){}),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Position')),
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('Experience')),
                  DataColumn(label: Text('Notice')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Date')),
                ],
                rows: mockCandidates.map((c) => DataRow(
                  onSelectChanged: (_) => context.go('/candidates/${c['id']}'),
                  cells: [
                    DataCell(Text(c['name']!)),
                    DataCell(Text(c['position']!)),
                    DataCell(Text(c['location']!)),
                    DataCell(Text(c['experience']!)),
                    DataCell(Text(c['notice']!)),
                    DataCell(Chip(label: Text(c['status']!))),
                    DataCell(Text(c['date']!)),
                  ]
                )).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
