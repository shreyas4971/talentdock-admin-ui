
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/page_container.dart';

class CandidateDetailsScreen extends StatelessWidget {
  final String id;
  const CandidateDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                const SizedBox(width: 16),
                const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 32)),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('John Doe', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Flutter Developer • Application ID: APP-10023', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    ],
                  ),
                ),
                Chip(label: const Text('Review', style: TextStyle(color: Colors.white)), backgroundColor: Colors.orange),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: (){}, child: const Text('Change Status')),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCard('Personal Information', [
                        _info('Email', 'john.doe@example.com'),
                        _info('Phone', '+1 555-0198'),
                        _info('Location', 'Chicago, IL'),
                      ]),
                      const SizedBox(height: 24),
                      _buildCard('Career Information', [
                        _info('Highest Education', 'Bachelor\'s Degree'),
                        _info('Employment Status', 'Experienced'),
                        _info('Current Company', 'TechCorp'),
                        _info('Total Experience', '3 Years'),
                        _info('Notice Period', '30 Days'),
                        _info('Expected Salary', '\$120k'),
                      ]),
                      const SizedBox(height: 24),
                      _buildCard('Resume', [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                              const SizedBox(width: 16),
                              const Expanded(child: Text('John_Doe_Resume.pdf', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                              OutlinedButton(onPressed: (){}, child: const Text('Preview')),
                              const SizedBox(width: 8),
                              ElevatedButton(onPressed: (){}, child: const Text('Download')),
                            ],
                          ),
                        )
                      ])
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCard('Recruiter Notes', [
                        TextField(decoration: const InputDecoration(hintText: 'Add a note...'), maxLines: 2),
                        const SizedBox(height: 8),
                        Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: (){}, child: const Text('Save Note'))),
                        const Divider(height: 32),
                        const ListTile(title: Text('Strong technical skills, fits the budget.'), subtitle: Text('Today, 10:30 AM')),
                      ]),
                      const SizedBox(height: 24),
                      _buildCard('Timeline', [
                        _timelineItem('Interview Scheduled', 'Yesterday'),
                        _timelineItem('Status changed to Review', '2 Days ago'),
                        _timelineItem('Application Submitted', '3 Days ago'),
                      ])
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...children
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _timelineItem(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 12, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(child: Text(text)),
          Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }
}
