
import 'package:flutter/material.dart';
import '../../widgets/page_container.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email Templates', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _templateItem('Interview Invitation', 'Template for inviting candidates for an interview.'),
                _templateItem('Offer Letter', 'Standard offer letter template.'),
                _templateItem('Rejection Email', 'Polite rejection email.'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _templateItem(String title, String desc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: Wrap(
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: (){}),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: (){}),
          ],
        ),
      ),
    );
  }
}
