import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../api_client.dart';

class ApplicationFormScreen extends ConsumerStatefulWidget {
  final String positionId;
  const ApplicationFormScreen({super.key, required this.positionId});

  @override
  ConsumerState<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends ConsumerState<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  
  // Optional fields
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _currentCompanyCtrl = TextEditingController();
  final _currentRoleCtrl = TextEditingController();
  final _expectedSalaryCtrl = TextEditingController();
  final _noticePeriodCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();

  PlatformFile? _resumeFile;
  bool _isSubmitting = false;

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) {
      setState(() => _resumeFile = result.files.first);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_resumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resume is required')));
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final dio = ref.read(dioProvider);
      
      final formData = FormData.fromMap({
        'positionId': widget.positionId,
        'firstName': _firstNameCtrl.text,
        'lastName': _lastNameCtrl.text,
        'email': _emailCtrl.text,
        'phone': _phoneCtrl.text,
        'experienceYears': _experienceCtrl.text,
        'city': _cityCtrl.text,
        'country': _countryCtrl.text,
        'currentCompany': _currentCompanyCtrl.text,
        'currentRole': _currentRoleCtrl.text,
        'expectedSalary': _expectedSalaryCtrl.text,
        'noticePeriod': _noticePeriodCtrl.text,
        'linkedin': _linkedinCtrl.text,
        'portfolio': _portfolioCtrl.text,
      });

      if (_resumeFile!.bytes != null) {
        formData.files.add(MapEntry(
          'resume',
          MultipartFile.fromBytes(_resumeFile!.bytes!, filename: _resumeFile!.name),
        ));
      }

      final res = await dio.post('/applications', data: formData);
      final refId = res.data['data']['referenceId'];
      
      if (mounted) context.go('/success?refId=$refId');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Position')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: SizedBox(
            width: 600,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Required Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _firstNameCtrl, decoration: const InputDecoration(labelText: 'First Name*'), validator: (v) => v!.isEmpty ? 'Required' : null)),
                          const SizedBox(width: 16),
                          Expanded(child: TextFormField(controller: _lastNameCtrl, decoration: const InputDecoration(labelText: 'Last Name*'), validator: (v) => v!.isEmpty ? 'Required' : null)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email*'), validator: (v) => !v!.contains('@') ? 'Invalid email' : null)),
                          const SizedBox(width: 16),
                          Expanded(child: TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone*'), validator: (v) => v!.isEmpty ? 'Required' : null)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(controller: _experienceCtrl, decoration: const InputDecoration(labelText: 'Years of Experience*'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
                      
                      const SizedBox(height: 32),
                      const Text('Optional Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City'))),
                          const SizedBox(width: 16),
                          Expanded(child: TextFormField(controller: _countryCtrl, decoration: const InputDecoration(labelText: 'Country'))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _currentCompanyCtrl, decoration: const InputDecoration(labelText: 'Current Company'))),
                          const SizedBox(width: 16),
                          Expanded(child: TextFormField(controller: _currentRoleCtrl, decoration: const InputDecoration(labelText: 'Current Role'))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _expectedSalaryCtrl, decoration: const InputDecoration(labelText: 'Expected Salary'))),
                          const SizedBox(width: 16),
                          Expanded(child: TextFormField(controller: _noticePeriodCtrl, decoration: const InputDecoration(labelText: 'Notice Period'))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(controller: _linkedinCtrl, decoration: const InputDecoration(labelText: 'LinkedIn URL')),
                      const SizedBox(height: 16),
                      TextFormField(controller: _portfolioCtrl, decoration: const InputDecoration(labelText: 'Portfolio URL')),
                      
                      const SizedBox(height: 32),
                      const Text('Resume / CV*', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _pickResume,
                        icon: const Icon(Icons.upload_file),
                        label: Text(_resumeFile?.name ?? 'Select Resume (PDF, DOCX)'),
                      ),
                      
                      const SizedBox(height: 32),
                      _isSubmitting
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                              child: const Text('Submit Application', style: TextStyle(fontSize: 18)),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
