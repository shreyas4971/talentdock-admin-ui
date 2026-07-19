import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CandidateListScreen extends StatelessWidget {
  const CandidateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
              hint: const Text('All Positions'),
              items: ['All Positions', 'Senior Flutter Developer', 'UI/UX Designer'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {},
            ),
            const SizedBox(width: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                constraints: const BoxConstraints(maxWidth: 200),
              ),
              hint: const Text('All Statuses'),
              items: ['All Statuses', 'Applied', 'Reviewing', 'Interview', 'Offer', 'Rejected', 'Hired'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {},
            ),
          ],
        ),
        const SizedBox(height: 32),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
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
                rows: List.generate(10, (index) {
                  return DataRow(
                    cells: [
                      DataCell(Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: Text('C${index + 1}', style: TextStyle(color: Colors.blue.shade700)),
                          ),
                          const SizedBox(width: 12),
                          Text('Candidate ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      )),
                      DataCell(Text(index % 2 == 0 ? 'Senior Flutter Developer' : 'UI/UX Designer')),
                      DataCell(Text('${(index % 5) + 2} Years')),
                      DataCell(Text(index % 3 == 0 ? 'Immediate' : '30 Days')),
                      DataCell(
                        Chip(
                          label: Text(index % 4 == 0 ? 'Interview' : 'Reviewing'),
                          backgroundColor: index % 4 == 0 ? Colors.purple.shade50 : Colors.blue.shade50,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.blueAccent),
                          onPressed: () => context.go('/candidates/${index + 1}'),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
