import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../mock_data.dart';

class PositionListScreen extends StatelessWidget {
  const PositionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            IconButton(icon: const Icon(Icons.filter_list), onPressed: (){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filter dialog opened')));
            }),
          ],
        ),
        const SizedBox(height: 32),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mockPositions.length,
          itemBuilder: (context, index) {
            final pos = mockPositions[index];
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
                          Text(pos['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text('${pos['department']} • ${pos['location']}', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                              Text('${pos['type']}', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                              Text('${pos['experience']}', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Chip(
                          label: Text(pos['status'] as String),
                          backgroundColor: pos['status'] == 'Published' ? Colors.green.shade50 : Colors.grey.shade100,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        const SizedBox(height: 8),
                        Text('${pos['applications']} Applications', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      ],
                    ),
                    const SizedBox(width: 24),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: Colors.black54),
                      onSelected: (val) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$val action selected')));
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'view', child: Text('View Candidates')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'dup', child: Text('Duplicate')),
                        const PopupMenuItem(value: 'archive', child: Text('Archive')),
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
