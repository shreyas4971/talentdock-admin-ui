import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';
import '../utils/file_helper.dart';

class CandidateDetailsScreen extends ConsumerStatefulWidget {
  final String id;
  const CandidateDetailsScreen({super.key, required this.id});

  @override
  ConsumerState<CandidateDetailsScreen> createState() => _CandidateDetailsScreenState();
}

class _CandidateDetailsScreenState extends ConsumerState<CandidateDetailsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _data;

  final TextEditingController _noteController = TextEditingController();
  bool _isAddingNote = false;
  bool _isUpdatingStatus = false;
  bool _isDownloadingResume = false;
  bool _isPreviewingResume = false;

  @override
  void initState() {
    super.initState();
    _loadCandidateDetails();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCandidateDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(adminApiClientProvider);
      final details = await client.getCandidateDetails(widget.id);
      if (mounted) {
        setState(() {
          _data = details;
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

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdatingStatus = true);
    try {
      final client = ref.read(adminApiClientProvider);
      await client.updateCandidateStatus(widget.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Candidate status updated to $newStatus')),
        );
      }
      await _loadCandidateDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: ${getFriendlyErrorMessage(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  void _showMoveStageDialog(String currentStatus) {
    final stages = ['APPLIED', 'REVIEWING', 'SHORTLISTED', 'INTERVIEW', 'OFFER', 'HIRED'];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Move to Stage'),
        children: stages.map((stage) {
          final isCurrent = stage.toUpperCase() == currentStatus.toUpperCase();
          return SimpleDialogOption(
            onPressed: isCurrent ? null : () {
              Navigator.pop(ctx);
              _updateStatus(stage);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(stage, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                if (isCurrent) const Icon(Icons.check, size: 18, color: Colors.blueAccent),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _addNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isAddingNote = true);
    try {
      final client = ref.read(adminApiClientProvider);
      await client.addCandidateNote(widget.id, text);
      _noteController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added successfully')),
        );
      }
      await _loadCandidateDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add note: ${getFriendlyErrorMessage(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingNote = false);
    }
  }

  Future<void> _handleResumePreview() async {
    setState(() => _isPreviewingResume = true);
    try {
      final client = ref.read(adminApiClientProvider);
      final bytes = await client.downloadResumeBytes(widget.id);
      previewFileWeb(bytes, mimeType: 'application/pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to preview resume: ${getFriendlyErrorMessage(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPreviewingResume = false);
    }
  }

  Future<void> _handleResumeDownload(String fileName) async {
    setState(() => _isDownloadingResume = true);
    try {
      final client = ref.read(adminApiClientProvider);
      final bytes = await client.downloadResumeBytes(widget.id);
      downloadFileWeb(bytes, fileName, mimeType: 'application/pdf');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resume download started for $fileName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download resume: ${getFriendlyErrorMessage(e)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloadingResume = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(64.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null || _data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage ?? 'Candidate not found', style: const TextStyle(color: Colors.red, fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadCandidateDetails, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final candidate = _data!['candidate'] as Map<String, dynamic>? ?? {};
    final application = _data!['application'] as Map<String, dynamic>? ?? {};
    final position = _data!['position'] as Map<String, dynamic>? ?? {};
    final documents = (_data!['documents'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final notes = (_data!['notes'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final timeline = (_data!['timeline'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    final currentStatus = (application['status'] ?? candidate['status'] ?? 'APPLIED').toString();

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
                onPressed: _isUpdatingStatus ? null : () => _showMoveStageDialog(currentStatus),
                child: _isUpdatingStatus
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Move to Next Stage'),
              ),
            if (isDesktop) const SizedBox(width: 16),
            if (isDesktop)
              OutlinedButton(
                onPressed: _isUpdatingStatus ? null : () => _updateStatus('REJECTED'),
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
                  onPressed: _isUpdatingStatus ? null : () => _showMoveStageDialog(currentStatus),
                  child: const Text('Move Stage'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isUpdatingStatus ? null : () => _updateStatus('REJECTED'),
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
                        _buildPersonalCard(candidate, position, application),
                        const SizedBox(height: 24),
                        _buildCareerCard(candidate),
                        const SizedBox(height: 24),
                        _buildResumeCard(context, documents),
                        const SizedBox(height: 24),
                        _buildTimelineCard(timeline),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: _buildNotesCard(context, notes),
                  )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPersonalCard(candidate, position, application),
                  const SizedBox(height: 24),
                  _buildCareerCard(candidate),
                  const SizedBox(height: 24),
                  _buildResumeCard(context, documents),
                  const SizedBox(height: 24),
                  _buildTimelineCard(timeline),
                  const SizedBox(height: 24),
                  _buildNotesCard(context, notes),
                ],
              )
      ],
    );
  }

  Widget _buildPersonalCard(Map<String, dynamic> candidate, Map<String, dynamic> position, Map<String, dynamic> application) {
    final firstName = candidate['firstName']?.toString() ?? '';
    final lastName = candidate['lastName']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();
    final nameDisplay = fullName.isNotEmpty ? fullName : (candidate['name']?.toString() ?? 'Candidate');
    final initial = nameDisplay.isNotEmpty ? nameDisplay[0].toUpperCase() : 'C';

    final posTitle = position['title']?.toString() ?? candidate['position']?.toString() ?? 'Software Developer';
    final refId = application['referenceId']?.toString() ?? candidate['referenceId']?.toString() ?? '-';
    final email = candidate['email']?.toString() ?? '-';
    final phone = candidate['phone']?.toString() ?? '-';
    final city = candidate['city']?.toString() ?? '';
    final state = candidate['state']?.toString() ?? '';
    final locationStr = [city, state].where((s) => s.isNotEmpty).join(', ');
    final locationDisplay = locationStr.isNotEmpty ? locationStr : (candidate['location']?.toString() ?? 'Remote');
    final portfolio = candidate['portfolioUrl']?.toString() ?? candidate['portfolio']?.toString() ?? candidate['linkedinUrl']?.toString() ?? '-';

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
                  child: Text(initial, style: TextStyle(color: Colors.blue.shade700, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nameDisplay, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(posTitle, style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
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
                Expanded(child: _InfoItem(icon: Icons.confirmation_number_outlined, label: 'Application Reference ID', value: refId)),
                Expanded(child: _InfoItem(icon: Icons.email, label: 'Email', value: email)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _InfoItem(icon: Icons.phone, label: 'Phone', value: phone)),
                Expanded(child: _InfoItem(icon: Icons.location_on, label: 'Location', value: locationDisplay)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _InfoItem(icon: Icons.link, label: 'Portfolio', value: portfolio)),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerCard(Map<String, dynamic> candidate) {
    final exp = candidate['totalExperience']?.toString() ?? candidate['experience']?.toString() ?? '-';
    final notice = candidate['noticePeriod']?.toString() ?? candidate['notice']?.toString() ?? '-';
    final salary = candidate['expectedSalary']?.toString() ?? candidate['salary']?.toString() ?? '-';

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
                Expanded(child: _InfoItem(icon: Icons.work, label: 'Total Experience', value: exp)),
                Expanded(child: _InfoItem(icon: Icons.timer, label: 'Notice Period', value: notice)),
                Expanded(child: _InfoItem(icon: Icons.attach_money, label: 'Expected Salary', value: salary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeCard(BuildContext context, List<Map<String, dynamic>> documents) {
    final doc = documents.isNotEmpty ? documents.first : null;
    final fileName = doc?['fileName']?.toString() ?? 'resume.pdf';
    final fileSizeNum = doc?['fileSize'];
    final fileSizeDisplay = fileSizeNum is num
        ? '${(fileSizeNum / (1024 * 1024)).toStringAsFixed(1)} MB'
        : 'PDF Document';

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(fileSizeDisplay, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: _isPreviewingResume
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.visibility),
                    label: const Text('Preview'),
                    onPressed: (_isPreviewingResume || _isDownloadingResume) ? null : () => _handleResumePreview(),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: _isDownloadingResume
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.download),
                    label: const Text('Download'),
                    onPressed: (_isPreviewingResume || _isDownloadingResume) ? null : () => _handleResumeDownload(fileName),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(List<Map<String, dynamic>> timeline) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Timeline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 24),
            if (timeline.isEmpty)
              Text('No timeline events recorded yet.', style: TextStyle(color: Colors.grey.shade600))
            else
              ...timeline.map((event) {
                final eventType = event['eventType']?.toString() ?? 'EVENT';
                final desc = event['description']?.toString() ?? event['note']?.toString() ?? eventType;
                final dateStr = event['createdAt']?.toString() ?? '';
                final parsedDate = DateTime.tryParse(dateStr);
                final dateFormatted = parsedDate != null
                    ? '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}'
                    : dateStr;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.blueAccent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(desc, style: const TextStyle(fontWeight: FontWeight.w600)),
                            if (dateFormatted.isNotEmpty)
                              Text(dateFormatted, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, List<Map<String, dynamic>> notes) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recruiter Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 24),
            TextField(
              controller: _noteController,
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
              child: ElevatedButton(
                onPressed: _isAddingNote ? null : _addNote,
                child: _isAddingNote
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Add Note'),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            if (notes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text('No recruiter notes yet.', style: TextStyle(color: Colors.grey.shade500)),
                ),
              )
            else
              ...notes.map((n) {
                final author = n['authorName']?.toString() ?? n['authorId']?.toString() ?? 'Recruiter';
                final content = n['content']?.toString() ?? n['note']?.toString() ?? '';
                final dateStr = n['createdAt']?.toString() ?? '';
                final parsedDate = DateTime.tryParse(dateStr);
                final timeDisplay = parsedDate != null ? _formatTimeAgo(parsedDate) : dateStr;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _NoteItem(
                    name: author,
                    time: timeDisplay,
                    text: content,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
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
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'R';
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
              CircleAvatar(radius: 12, backgroundColor: Colors.blue.shade100, child: Text(initial, style: const TextStyle(fontSize: 10))),
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
