import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../api_client.dart';

class ApplicationFormScreen extends ConsumerStatefulWidget {
  final String positionId;
  final int initialStep;
  const ApplicationFormScreen({super.key, required this.positionId, this.initialStep = 0});

  @override
  ConsumerState<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends ConsumerState<ApplicationFormScreen> {
  late int _currentStep;
  
  String? _jobTitle;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _loadPositionTitle();
  }

  Future<void> _loadPositionTitle() async {
    try {
      final pos = await ref.read(candidateApiClientProvider).getPositionById(widget.positionId);
      if (mounted && pos != null && pos['title'] != null) {
        setState(() {
          _jobTitle = pos['title'].toString();
        });
      }
    } catch (_) {}
  }
  
  @override
  void didUpdateWidget(ApplicationFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStep != oldWidget.initialStep) {
      setState(() {
        _currentStep = widget.initialStep;
      });
    }
  }
  
  // Forms
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();

  // Step 1: Personal Info
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  // Step 2: Career Info
  String? _highestEducation;
  String _empStatus = 'Fresher';
  final _totalExpCtrl = TextEditingController();
  final _currentCompanyCtrl = TextEditingController();
  final _currentDesignationCtrl = TextEditingController();

  // Step 3: Expectations
  final _expectedSalaryCtrl = TextEditingController();
  final _currentSalaryCtrl = TextEditingController();
  final _noticePeriodCtrl = TextEditingController();
  final _joiningDateCtrl = TextEditingController();
  final _additionalInfoCtrl = TextEditingController();

  // Step 4: Resume
  PlatformFile? _resumeFile;
  bool _declarationChecked = false;
  bool _isSubmitting = false;

  void _submit() async {
    if (_resumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload your resume (PDF only, maximum 2 MB).')));
      return;
    }
    if (!_declarationChecked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please accept the declaration to submit.')));
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final client = ref.read(candidateApiClientProvider);
      final result = await client.submitApplication(
        positionId: widget.positionId,
        firstName: _firstNameCtrl.text,
        lastName: _lastNameCtrl.text,
        email: _emailCtrl.text,
        phone: _mobileCtrl.text,
        city: _cityCtrl.text,
        state: _stateCtrl.text,
        dob: _dobCtrl.text,
        highestEducation: _highestEducation,
        empStatus: _empStatus,
        totalExp: _totalExpCtrl.text,
        currentCompany: _currentCompanyCtrl.text,
        currentDesignation: _currentDesignationCtrl.text,
        expectedSalary: _expectedSalaryCtrl.text,
        currentSalary: _currentSalaryCtrl.text,
        noticePeriod: _noticePeriodCtrl.text,
        joiningDate: _joiningDateCtrl.text,
        additionalInfo: _additionalInfoCtrl.text,
        resumeFile: _resumeFile!,
      );

      final refId = result['referenceId'];
      final email = result['candidateEmail'] ?? result['email'] ?? _emailCtrl.text;
      
      if (refId != null && mounted) {
        context.go('/success?refId=$refId&email=$email');
      } else if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to submit application. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getFriendlyErrorMessage(e)),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _onStepContinue() {
    bool isStepValid = false;
    if (_currentStep == 0) isStepValid = _step1FormKey.currentState!.validate();
    else if (_currentStep == 1) isStepValid = _step2FormKey.currentState!.validate();
    else if (_currentStep == 2) isStepValid = _step3FormKey.currentState!.validate();
    else if (_currentStep == 3) isStepValid = true;

    if (isStepValid) {
      if (_currentStep < 3) {
        setState(() => _currentStep += 1);
      } else {
        _submit();
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = _jobTitle != null && _jobTitle!.isNotEmpty ? 'Apply for $_jobTitle' : 'Apply for Position';

    return Scaffold(
      appBar: AppBar(title: const Text('TalentDock Careers', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 12))
                ]
              ),
              child: _isSubmitting 
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 24),
                          Text('Submitting your application...', style: TextStyle(fontSize: 18))
                        ],
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayTitle, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.white,
                          ),
                          child: Stepper(
                          type: StepperType.horizontal,
                          elevation: 0,
                          currentStep: _currentStep,
                          onStepContinue: _onStepContinue,
                          onStepCancel: _onStepCancel,
                          onStepTapped: (step) => setState(() => _currentStep = step),
                          controlsBuilder: (context, details) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 32.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (_currentStep > 0)
                                    TextButton(
                                      onPressed: details.onStepCancel,
                                      child: const Text('Back'),
                                    ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: details.onStepContinue,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(_currentStep == 3 ? 'Submit Application' : 'Continue'),
                                  ),
                                ],
                              ),
                            );
                          },
                          steps: [
                            Step(
                              title: const Text('Personal Info', style: TextStyle(fontWeight: FontWeight.bold)),
                              isActive: _currentStep >= 0,
                              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                              content: Form(
                                key: _step1FormKey,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: _buildTextField('First Name *', _firstNameCtrl, validator: _requiredValidator)),
                                        const SizedBox(width: 16),
                                        Expanded(child: _buildTextField('Last Name *', _lastNameCtrl, validator: _requiredValidator)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(child: _buildTextField('Email Address *', _emailCtrl, validator: _emailValidator)),
                                        const SizedBox(width: 16),
                                        Expanded(child: _buildTextField('Mobile Number *', _mobileCtrl, validator: _phoneValidator)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(child: _buildTextField('Current City *', _cityCtrl, validator: _requiredValidator)),
                                        const SizedBox(width: 16),
                                        Expanded(child: _buildTextField('Current State *', _stateCtrl, validator: _requiredValidator)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField('Date of Birth (Optional)', _dobCtrl),
                                  ],
                                ),
                              ),
                            ),
                            Step(
                              title: const Text('Career Info', style: TextStyle(fontWeight: FontWeight.bold)),
                              isActive: _currentStep >= 1,
                              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                              content: Form(
                                key: _step2FormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Career Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 24),
                                    DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        label: const Text.rich(
                                          TextSpan(
                                            text: 'Highest Education',
                                            children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
                                          ),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      value: _highestEducation,
                                      items: ['High School', 'Diploma', 'Bachelor\'s Degree', 'Master\'s Degree', 'PhD', 'Other']
                                          .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                      onChanged: (v) => setState(() => _highestEducation = v),
                                      validator: (v) => v == null ? 'Required' : null,
                                    ),
                                    const SizedBox(height: 24),
                                    const Text.rich(
                                      TextSpan(
                                        text: 'Current Status',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Radio<String>(value: 'Student', groupValue: _empStatus, onChanged: (v) => setState(() => _empStatus = v!)),
                                        const Text('Student'),
                                        const SizedBox(width: 24),
                                        Radio<String>(value: 'Fresher', groupValue: _empStatus, onChanged: (v) => setState(() => _empStatus = v!)),
                                        const Text('Fresher'),
                                        const SizedBox(width: 24),
                                        Radio<String>(value: 'Experienced', groupValue: _empStatus, onChanged: (v) => setState(() => _empStatus = v!)),
                                        const Text('Experienced'),
                                      ],
                                    ),
                                    if (_empStatus == 'Experienced') ...[
                                      const SizedBox(height: 24),
                                      _buildTextField('Years of Experience *', _totalExpCtrl, validator: _requiredValidator, isNumber: true),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(child: _buildTextField('Current Company (Optional)', _currentCompanyCtrl)),
                                          const SizedBox(width: 16),
                                          Expanded(child: _buildTextField('Current Designation (Optional)', _currentDesignationCtrl)),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            Step(
                              title: const Text('Expectations', style: TextStyle(fontWeight: FontWeight.bold)),
                              isActive: _currentStep >= 2,
                              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                              content: Form(
                                key: _step3FormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Expectations & Additional Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(child: _buildTextField('Expected Salary (Optional)', _expectedSalaryCtrl)),
                                        const SizedBox(width: 16),
                                        Expanded(child: _buildTextField('Current Salary (Optional)', _currentSalaryCtrl)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(child: _buildTextField('Notice Period *', _noticePeriodCtrl, validator: _requiredValidator)),
                                        const SizedBox(width: 16),
                                        Expanded(child: _buildTextField('Earliest Joining Date (Optional)', _joiningDateCtrl)),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.teal.shade100),
                                      ),
                                      child: const Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.lightbulb_outline, color: Colors.teal),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Want to stand out?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Your resume already provides most of the information we need. If you\'d like to strengthen your application, you may share anything that isn\'t already obvious in your resume, such as: important projects, technical expertise, certifications, portfolio, LinkedIn profile, GitHub, achievements, awards, or publications. This section is completely optional.',
                                                  style: TextStyle(height: 1.5, color: Colors.black87),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildTextField('Additional Information', _additionalInfoCtrl, maxLines: 6),
                                  ],
                                ),
                              ),
                            ),
                            Step(
                              title: const Text('Resume', style: TextStyle(fontWeight: FontWeight.bold)),
                              isActive: _currentStep >= 3,
                              state: StepState.indexed,
                              content: Form(
                                key: _step4FormKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Resume (PDF only, maximum 2 MB)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Upload your most recent resume as a PDF. Maximum file size: 2 MB.',
                                      style: TextStyle(color: Colors.black87, fontSize: 14),
                                    ),
                                    const SizedBox(height: 20),
                                    Card(
                                      color: Colors.blue.shade50,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.blue.shade200)),
                                      child: const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.insert_drive_file, color: Colors.blue),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Recommended Resume File Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                                                  SizedBox(height: 8),
                                                  Text('Please name your resume using the following format: FirstName_LastName.pdf (e.g. John_Smith.pdf). This is only a recommendation.', style: TextStyle(height: 1.4)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    InkWell(
                                      onTap: () async {
                                        final result = await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf'],
                                          withData: true,
                                        );
                                        if (result != null && result.files.isNotEmpty) {
                                          final file = result.files.first;
                                          final isPdf = file.name.toLowerCase().endsWith('.pdf');
                                          final isUnder2Mb = file.size <= 2 * 1024 * 1024;
                                          if (!isPdf || !isUnder2Mb) {
                                            setState(() => _resumeFile = null);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Invalid file. Please select a genuine PDF document up to 2 MB.'),
                                                  backgroundColor: Colors.redAccent,
                                                ),
                                              );
                                            }
                                          } else {
                                            setState(() => _resumeFile = file);
                                          }
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: Colors.teal.withOpacity(0.3), width: 2, style: BorderStyle.solid),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          children: [
                                            const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.teal),
                                            const SizedBox(height: 16),
                                            Text(
                                              _resumeFile != null ? 'Selected: ${_resumeFile!.name}' : 'Drag & Drop your resume here, or Click to Browse',
                                              style: TextStyle(fontSize: 16, color: _resumeFile != null ? Colors.teal : Colors.black87, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.only(top: 8.0),
                                              child: Text('Supported format: PDF only (Maximum 2 MB)', style: TextStyle(color: Colors.black54, fontSize: 14)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    CheckboxListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: const Text('I confirm that all the information provided is true and accurate to the best of my knowledge.', style: TextStyle(fontSize: 14)),
                                      value: _declarationChecked,
                                      onChanged: (v) => setState(() => _declarationChecked = v!),
                                      controlAffinity: ListTileControlAffinity.leading,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, {String? Function(String?)? validator, int maxLines = 1, bool isNumber = false}) {
    final bool isRequired = labelText.contains('*');
    final String cleanLabel = labelText.replaceAll(' *', '');

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        label: Text.rich(
          TextSpan(
            text: cleanLabel,
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: validator,
    );
  }

  String? _requiredValidator(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _emailValidator(String? v) => (v == null || !v.contains('@')) ? 'Valid email required' : null;
  String? _phoneValidator(String? v) => (v == null || v.length < 5) ? 'Valid phone required' : null;
}
