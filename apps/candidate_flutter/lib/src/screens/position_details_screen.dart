import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../mock_data.dart';

class PositionDetailsScreen extends StatelessWidget {
  final String id;
  const PositionDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final pos = mockPositions.firstWhere((p) => p['id'] == id, orElse: () => {});
    if (pos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Position Not Found')),
        body: const Center(child: Text('The position you are looking for does not exist.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(32.0),
            children: [
              Text(pos['title'], style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildIconChip(Icons.domain, pos['department']),
                  _buildIconChip(Icons.location_on, pos['location']),
                  _buildIconChip(Icons.work, pos['employmentType']),
                  _buildIconChip(Icons.access_time, pos['experience']),
                ],
              ),
              const SizedBox(height: 48),
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 16),
              Text(pos['description'], style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87)),
              const SizedBox(height: 32),
              const Text('Responsibilities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 16),
              ...List<String>.from(pos['responsibilities']).map((r) => _buildBulletPoint(r)),
              const SizedBox(height: 32),
              const Text('Requirements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 16),
              ...List<String>.from(pos['requirements']).map((r) => _buildBulletPoint(r)),
              const SizedBox(height: 32),
              const Text('Benefits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 16),
              ...List<String>.from(pos['benefits']).map((r) => _buildBulletPoint(r)),
              const SizedBox(height: 48),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => context.go('/positions/$id/apply'),
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Apply Now'),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.teal),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87))),
        ],
      ),
    );
  }
}
