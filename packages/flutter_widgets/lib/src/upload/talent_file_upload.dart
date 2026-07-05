import 'package:flutter/material.dart';

class TalentFileUpload extends StatelessWidget {
  final String label;
  final VoidCallback onBrowse;
  final double? uploadProgress;

  const TalentFileUpload({
    super.key,
    required this.label,
    required this.onBrowse,
    this.uploadProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onBrowse,
            child: const Text('Browse Files'),
          ),
          if (uploadProgress != null) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: uploadProgress),
          ]
        ],
      ),
    );
  }
}
