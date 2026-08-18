import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../mock_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    
    int openPositions = mockPositions.where((p) => p['status'] == 'Published').length;
    int newApplications = mockCandidates.where((c) => c['isOpened'] == false).length;
    int pendingReview = mockCandidates.where((c) => c['isOpened'] == true && c['hasDecision'] == false).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            SizedBox(width: isDesktop ? (MediaQuery.of(context).size.width > 1200 ? 250 : 200) : double.infinity, child: _StatCard('Open Positions', '$openPositions', Icons.work)),
            SizedBox(width: isDesktop ? (MediaQuery.of(context).size.width > 1200 ? 250 : 200) : double.infinity, child: _StatCard('New Applications', '$newApplications', Icons.today)),
            SizedBox(width: isDesktop ? (MediaQuery.of(context).size.width > 1200 ? 250 : 200) : double.infinity, child: _StatCard('Pending Review', '$pendingReview', Icons.pending_actions)),
          ],
        ),
        const SizedBox(height: 32),
        isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildPositionApplicationSummary(context)),
                  const SizedBox(width: 32),
                  Expanded(flex: 1, child: _buildQuickActions(context)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPositionApplicationSummary(context),
                  const SizedBox(height: 32),
                  _buildQuickActions(context),
                ],
              ),
      ],
    );
  }

  Widget _buildPositionApplicationSummary(BuildContext context) {
    List<Map<String, dynamic>> positions = mockPositions.toList();
    
    List<Map<String, dynamic>> pinnedPositions = positions.where((p) => p['pinned'] == true).toList();
    List<Map<String, dynamic>> unpinnedPositions = positions.where((p) => p['pinned'] != true).toList();
    
    // Sort pinned and unpinned by date descending just to be safe
    pinnedPositions.sort((a, b) {
      DateTime aDate = DateTime.parse(a['postedDate'] as String);
      DateTime bDate = DateTime.parse(b['postedDate'] as String);
      return bDate.compareTo(aDate);
    });
    
    unpinnedPositions.sort((a, b) {
      DateTime aDate = DateTime.parse(a['postedDate'] as String);
      DateTime bDate = DateTime.parse(b['postedDate'] as String);
      return bDate.compareTo(aDate);
    });

    if (pinnedPositions.length > 3) {
      unpinnedPositions.insertAll(0, pinnedPositions.sublist(3));
      pinnedPositions = pinnedPositions.sublist(0, 3);
    }
    
    List<Map<String, dynamic>> finalPositions = [...pinnedPositions, ...unpinnedPositions];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Positions / Applications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...finalPositions.asMap().entries.map((entry) {
              int index = entry.key;
              var position = entry.value;
              return Card(
                elevation: 0,
                color: Colors.transparent,
                margin: const EdgeInsets.only(bottom: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ExpansionTile(
                  shape: const Border(),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
                    child: Text('${index + 1}', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          position['title'] as String,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (position['pinned'] == true) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.push_pin, size: 16, color: Colors.blueAccent),
                      ],
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Text('${position['applications']} applicants', style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(width: 12),
                        const Text('•', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 12),
                        Text(_formatTimeLive(position['postedDate'] as String), style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                      ],
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(position['pinned'] == true ? Icons.push_pin : Icons.push_pin_outlined, size: 18),
                            label: Text(position['pinned'] == true ? 'Unpin' : 'Pin'),
                          ),
                          TextButton.icon(
                            onPressed: () => context.go('/candidates'), // Mock routing to candidates list
                            icon: const Icon(Icons.people_outline, size: 18),
                            label: const Text('Applicants'),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            label: const Text('Remove', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatTimeLive(String isoDate) {
    final date = DateTime.parse(isoDate);
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Live today';
    if (diff.inDays == 1) return 'Live 1 day';
    if (diff.inDays < 30) return 'Live ${diff.inDays} days';
    if (diff.inDays < 365) return 'Live ${(diff.inDays / 30).floor()} months';
    return 'Live ${(diff.inDays / 365).floor()} years';
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create Position'),
                onPressed: () => context.go('/positions/new'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('View Candidates'),
                onPressed: () => context.go('/candidates'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;

  const _StatCard(this.title, this.count, this.icon);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blueAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.blueAccent, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(title, style: TextStyle(color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
