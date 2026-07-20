import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CandidateDetailsScreen extends StatelessWidget {
  final String id;
  const CandidateDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
            const SizedBox(width: 16),
            const Expanded(child: Text('Candidate Details', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            if (isDesktop) const Spacer(),
            if (isDesktop)
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Candidate moved to next stage')));
                },
                child: const Text('Move to Next Stage'),
              ),
            if (isDesktop) const SizedBox(width: 16),
            if (isDesktop)
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Candidate rejected')));
                },
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Reject'),
              ),
          ],
        ),
        if (!isDesktop) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Candidate moved to next stage')));
                  },
                  child: const Text('Move Stage'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Candidate rejected')));
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Reject'),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 32),
        isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildPersonalCard(),
                        const SizedBox(height: 24),
                        _buildCareerCard(),
                        const SizedBox(height: 24),
                        _buildResumeCard(context),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: _buildNotesCard(context),
                  )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPersonalCard(),
                  const SizedBox(height: 24),
                  _buildCareerCard(),
                  const SizedBox(height: 24),
                  _buildResumeCard(context),
                  const SizedBox(height: 24),
                  _buildNotesCard(context),
                ],
              )
      ],
    );
  }

  Widget _buildPersonalCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Personal Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.shade50,
                  child: Text('JD', style: TextStyle(color: Colors.blue.shade700, fontSize: 24)),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('John Doe', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Senior Flutter Developer', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _InfoItem(icon: Icons.email, label: 'Email', value: 'john.doe@example.com')),
                Expanded(child: _InfoItem(icon: Icons.phone, label: 'Phone', value: '+1 234 567 8900')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _InfoItem(icon: Icons.location_on, label: 'Location', value: 'New York, USA')),
                Expanded(child: _InfoItem(icon: Icons.link, label: 'Portfolio', value: 'github.com/johndoe')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Career Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _InfoItem(icon: Icons.work, label: 'Total Experience', value: '5 Years')),
                Expanded(child: _InfoItem(icon: Icons.timer, label: 'Notice Period', value: '30 Days')),
                Expanded(child: _InfoItem(icon: Icons.attach_money, label: 'Expected Salary', value: '\$120,000')),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Skills', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Flutter', 'Dart', 'Firebase', 'Riverpod', 'REST API'].map((s) => Chip(
                label: Text(s),
                backgroundColor: Colors.blue.shade50,
                side: BorderSide.none,
              )).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResumeCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resume', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 40),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('John_Doe_Resume.pdf', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('2.4 MB', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text('Preview'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Previewing John_Doe_Resume.pdf')));
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading John_Doe_Resume.pdf')));
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recruiter Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 24),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add a new note...',
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(onPressed: (){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note added')));
              }, child: const Text('Add Note')),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            _NoteItem(name: 'Sarah Smith', time: '2 hours ago', text: 'Strong candidate. Great communication skills.'),
            const SizedBox(height: 16),
            _NoteItem(name: 'Mike Johnson', time: '1 day ago', text: 'Technical round passed with flying colors.'),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoteItem extends StatelessWidget {
  final String name;
  final String time;
  final String text;
  const _NoteItem({required this.name, required this.time, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: Colors.blue.shade100, child: Text(name[0], style: const TextStyle(fontSize: 10))),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(text),
        ],
      ),
    );
  }
}
