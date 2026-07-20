import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            SizedBox(width: isDesktop ? (MediaQuery.of(context).size.width > 1200 ? 250 : 200) : double.infinity, child: const _StatCard('Open Positions', '12', Icons.work)),
            SizedBox(width: isDesktop ? (MediaQuery.of(context).size.width > 1200 ? 250 : 200) : double.infinity, child: const _StatCard('New Applications', '28', Icons.today)),
            SizedBox(width: isDesktop ? (MediaQuery.of(context).size.width > 1200 ? 250 : 200) : double.infinity, child: const _StatCard('Pending Review', '42', Icons.pending_actions)),
            SizedBox(width: isDesktop ? (MediaQuery.of(context).size.width > 1200 ? 250 : 200) : double.infinity, child: const _StatCard('Interviews Today', '5', Icons.video_call)),
          ],
        ),
        const SizedBox(height: 32),
        isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildRecentApplications()),
                  const SizedBox(width: 32),
                  Expanded(flex: 1, child: _buildUpcomingAndQuickActions(context)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecentApplications(),
                  const SizedBox(height: 32),
                  _buildUpcomingAndQuickActions(context),
                ],
              ),
      ],
    );
  }

  Widget _buildRecentApplications() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Recent Applications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Position')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Time')),
                ],
                rows: List.generate(10, (index) => DataRow(cells: [
                  DataCell(Text('Candidate ${index + 1}')),
                  DataCell(Text(index % 2 == 0 ? 'Flutter Dev' : 'Designer')),
                  DataCell(Text(index % 3 == 0 ? 'Review' : 'Applied')),
                  DataCell(Text('${index * 15} mins ago')),
                ])),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAndQuickActions(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Upcoming Interviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('John Doe'),
                  subtitle: Text('Flutter Dev\nToday, 2:00 PM'),
                  isThreeLine: true,
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Jane Smith'),
                  subtitle: Text('Designer\nTomorrow, 11:00 AM'),
                  isThreeLine: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Card(
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
        ),
      ],
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
