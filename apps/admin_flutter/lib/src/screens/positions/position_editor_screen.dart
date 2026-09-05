import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api_client.dart';

class PositionEditorScreen extends ConsumerStatefulWidget {
  final String? id;
  const PositionEditorScreen({super.key, this.id});

  @override
  ConsumerState<PositionEditorScreen> createState() => _PositionEditorScreenState();
}

class _PositionEditorScreenState extends ConsumerState<PositionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _deptController = TextEditingController();
  final _locationController = TextEditingController();
  final _minExpController = TextEditingController();
  final _maxExpController = TextEditingController();
  final _relevantExpController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _employmentType = 'Full-time';
  String _status = 'Draft';
  String _noticePeriod = '30 Days';
  bool _immediateJoiner = false;
  List<String> _specs = ['Flutter', 'Riverpod', 'REST API'];

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loadExistingPosition();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _deptController.dispose();
    _locationController.dispose();
    _minExpController.dispose();
    _maxExpController.dispose();
    _relevantExpController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingPosition() async {
    setState(() => _isLoading = true);
    try {
      final client = ref.read(adminApiClientProvider);
      final pos = await client.getPositionById(widget.id!);
      if (pos != null && mounted) {
        setState(() {
          _titleController.text = pos['title']?.toString() ?? '';
          _deptController.text = pos['department']?.toString() ?? '';
          _locationController.text = pos['location']?.toString() ?? '';
          _minExpController.text = (pos['minExperience'] ?? pos['minExp'] ?? '').toString();
          _maxExpController.text = (pos['maxExperience'] ?? pos['maxExp'] ?? '').toString();
          _relevantExpController.text = (pos['relevantExperience'] ?? '').toString();
          _descriptionController.text = pos['description']?.toString() ?? '';
          
          final emp = pos['employmentType']?.toString() ?? pos['type']?.toString();
          if (emp != null && ['Full-time', 'Part-time', 'Contract', 'Internship'].contains(emp)) {
            _employmentType = emp;
          }

          final st = pos['status']?.toString();
          if (st != null) {
            if (st.toUpperCase() == 'PUBLISHED') {
              _status = 'Published';
            } else if (st.toUpperCase() == 'ARCHIVED') {
              _status = 'Archived';
            } else {
              _status = 'Draft';
            }
          }

          final np = pos['noticePeriod']?.toString() ?? pos['maxNoticePeriod']?.toString();
          if (np != null && ['Immediate', '15 Days', '30 Days', '60 Days', '90+ Days'].contains(np)) {
            _noticePeriod = np;
          }

          _immediateJoiner = pos['immediateJoiner'] == true || pos['immediateJoinerRequired'] == true;

          final rawSpecs = pos['skills'] ?? pos['specifications'] ?? pos['specs'];
          if (rawSpecs is List) {
            _specs = rawSpecs.map((e) => e.toString()).toList();
          } else if (rawSpecs is String && rawSpecs.isNotEmpty) {
            _specs = rawSpecs.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load position: ${getFriendlyErrorMessage(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addSpecDialog() {
    final specInput = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Specification / Skill'),
        content: TextField(
          controller: specInput,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. TypeScript, SQL'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = specInput.text.trim();
              if (val.isNotEmpty && !_specs.contains(val)) {
                setState(() => _specs.add(val));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePosition({required String targetStatus}) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job Title is required')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final client = ref.read(adminApiClientProvider);

    final positionData = <String, dynamic>{
      'title': title,
      'department': _deptController.text.trim().isNotEmpty ? _deptController.text.trim() : 'General',
      'employmentType': _employmentType,
      'location': _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : 'Remote',
      'status': targetStatus,
      'minExperience': int.tryParse(_minExpController.text.trim()) ?? 0,
      'maxExperience': int.tryParse(_maxExpController.text.trim()) ?? 10,
      'relevantExperience': int.tryParse(_relevantExpController.text.trim()) ?? 0,
      'noticePeriod': _noticePeriod,
      'immediateJoiner': _immediateJoiner,
      'skills': _specs,
      'description': _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : 'Position details',
    };

    try {
      if (widget.id == null) {
        await client.createPosition(positionData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(targetStatus == 'PUBLISHED' ? 'Position published successfully' : 'Draft saved successfully')),
          );
          context.pop();
        }
      } else {
        await client.updatePosition(widget.id!, positionData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(targetStatus == 'PUBLISHED' ? 'Position published successfully' : 'Draft saved successfully')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save position: ${getFriendlyErrorMessage(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(64.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
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
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity,
                  child: _field('Job Title', _titleController),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity,
                  child: _field('Department', _deptController),
                ),
              ],
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Employment Type'),
                    value: _employmentType,
                    items: ['Full-time', 'Part-time', 'Contract', 'Internship'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _employmentType = v);
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity,
                  child: _field('Location', _locationController),
                ),
              ],
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Status'),
                    value: _status,
                    items: ['Draft', 'Published', 'Archived'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _status = v);
                    },
                  ),
                ),
              ],
            ),
          ]),
          _buildSection('Candidate Requirements', [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity,
                  child: _field('Minimum Experience', _minExpController, keyboardType: TextInputType.number),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity,
                  child: _field('Maximum Experience', _maxExpController, keyboardType: TextInputType.number),
                ),
              ],
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity,
                  child: _field('Relevant Experience Required', _relevantExpController, keyboardType: TextInputType.number),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 800 ? (MediaQuery.of(context).size.width > 1200 ? 300 : 250) : double.infinity,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Maximum Notice Period'),
                    value: _noticePeriod,
                    items: ['Immediate', '15 Days', '30 Days', '60 Days', '90+ Days'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _noticePeriod = v);
                    },
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              title: const Text('Immediate Joiner Required'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _immediateJoiner,
              onChanged: (v) => setState(() => _immediateJoiner = v ?? false),
            ),
          ]),
          _buildSection('Important Specifications', [
            const Text('Enter keywords/skills to filter candidates.'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ..._specs.map((s) => Chip(
                  label: Text(s),
                  onDeleted: () => setState(() => _specs.remove(s)),
                )),
                ActionChip(
                  label: const Text('Add Spec'),
                  onPressed: _addSpecDialog,
                ),
              ],
            ),
          ]),
          _buildSection('Job Description', [
            TextField(
              controller: _descriptionController,
              maxLines: 10,
              decoration: const InputDecoration(hintText: 'Enter complete Job Description here...'),
            ),
          ]),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSaving ? null : () => context.pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: _isSaving ? null : () => _savePosition(targetStatus: 'DRAFT'),
                child: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Draft'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _isSaving ? null : () => _savePosition(targetStatus: 'PUBLISHED'),
                child: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Publish'),
              ),
            ],
          ),
        ],
      ),
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

  Widget _field(String label, TextEditingController controller, {TextInputType? keyboardType}) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(labelText: label),
  );
}
