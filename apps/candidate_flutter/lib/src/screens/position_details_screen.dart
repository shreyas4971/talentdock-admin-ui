import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

class PositionDetailsScreen extends ConsumerStatefulWidget {
  final String id;
  const PositionDetailsScreen({super.key, required this.id});

  @override
  ConsumerState<PositionDetailsScreen> createState() => _PositionDetailsScreenState();
}

class _PositionDetailsScreenState extends ConsumerState<PositionDetailsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _pos;

  @override
  void initState() {
    super.initState();
    _loadPositionDetails();
  }

  Future<void> _loadPositionDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(candidateApiClientProvider);
      final pos = await client.getPositionById(widget.id);
      if (mounted) {
        setState(() {
          _pos = pos;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details', style: TextStyle(fontWeight: FontWeight.bold))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _pos == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Position Not Found')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage ?? 'The position you are looking for does not exist.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/positions'),
                  child: const Text('View Open Positions'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final pos = _pos!;
    final title = pos['title']?.toString() ?? 'Untitled Position';
    final department = pos['department']?.toString() ?? 'General';
    final location = pos['location']?.toString() ?? 'Remote';
    final employmentType = pos['employmentType']?.toString() ?? pos['type']?.toString() ?? 'Full-time';
    final experience = pos['experience']?.toString() ?? '1+ Years';
    final description = pos['description']?.toString() ?? '';

    List<String> parseList(dynamic raw) {
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [];
    }

    final responsibilities = parseList(pos['responsibilities']);
    final requirements = parseList(pos['requirements']);
    final benefits = parseList(pos['benefits']);

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
              Text(title, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildIconChip(Icons.domain, department),
                  _buildIconChip(Icons.location_on, location),
                  _buildIconChip(Icons.work, employmentType),
                  _buildIconChip(Icons.access_time, experience),
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 48),
                const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 16),
                Text(description, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87)),
              ],
              if (responsibilities.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text('Responsibilities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 16),
                ...responsibilities.map((r) => _buildBulletPoint(r)),
              ],
              if (requirements.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text('Requirements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 16),
                ...requirements.map((r) => _buildBulletPoint(r)),
              ],
              if (benefits.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text('Benefits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 16),
                ...benefits.map((r) => _buildBulletPoint(r)),
              ],
              const SizedBox(height: 48),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => context.go('/positions/${widget.id}/apply'),
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
