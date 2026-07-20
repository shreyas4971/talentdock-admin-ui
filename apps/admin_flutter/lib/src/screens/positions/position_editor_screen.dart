import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PositionEditorScreen extends StatefulWidget {
  final String? id;
  const PositionEditorScreen({super.key, this.id});

  @override
  State<PositionEditorScreen> createState() => _PositionEditorScreenState();
}

class _PositionEditorScreenState extends State<PositionEditorScreen> {
  final List<String> specs = ['Flutter', 'Riverpod', 'REST API'];
  bool _immediateJoiner = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
            const SizedBox(width: 16),
            Text(widget.id == null ? 'Create Position' : 'Edit Position', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 32),
        _buildSection('Basic Information', [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity, child: _field('Job Title')),
              SizedBox(width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity, child: _field('Department')),
            ],
          ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity, child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Employment Type'), 
                items: ['Full-time', 'Part-time', 'Contract', 'Internship'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
                onChanged: (v){}
              )),
              SizedBox(width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity, child: _field('Location')),
            ],
          ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity, child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'), 
                items: ['Draft', 'Published', 'Archived'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
                onChanged: (v){}
              )),
            ],
          ),
        ]),
        _buildSection('Candidate Requirements', [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity, child: _field('Minimum Experience')),
              SizedBox(width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity, child: _field('Maximum Experience')),
            ],
          ),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity, child: _field('Relevant Experience Required')), 
              SizedBox(width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity, child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Maximum Notice Period'), 
                items: ['Immediate', '15 Days', '30 Days', '60 Days', '90+ Days'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
                onChanged: (v){}
              )),
            ],
          ),
          CheckboxListTile(
            title: const Text('Immediate Joiner Required'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _immediateJoiner, 
            onChanged: (v) => setState(() => _immediateJoiner = v ?? false)
          ),
        ]),
        _buildSection('Important Specifications', [
          const Text('Enter keywords/skills to filter candidates.'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: <Widget>[...specs.map((s) => Chip(label: Text(s), onDeleted: (){})), ActionChip(label: const Text('Add Spec'), onPressed: (){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Spec clicked')));
            })],
          )
        ]),
        _buildSection('Job Description', [
          const TextField(maxLines: 10, decoration: InputDecoration(hintText: 'Enter complete Job Description here...')),
        ]),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
            const SizedBox(width: 16),
            OutlinedButton(onPressed: (){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved successfully')));
            }, child: const Text('Save Draft')),
            const SizedBox(width: 16),
            ElevatedButton(onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Position published successfully')));
              context.pop();
            }, child: const Text('Publish')),
          ],
        )
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 24),
            for (var child in children) Padding(padding: const EdgeInsets.only(bottom: 24), child: child),
          ],
        ),
      ),
    );
  }

  Widget _field(String label) => TextField(decoration: InputDecoration(labelText: label));
}
