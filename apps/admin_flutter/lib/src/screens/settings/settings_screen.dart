
import 'package:flutter/material.dart';
import '../../widgets/page_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            SwitchListTile(title: const Text('Dark Mode'), value: false, onChanged: (v){}),
            const Divider(),
            ListTile(title: const Text('Change Password'), trailing: const Icon(Icons.chevron_right), onTap: (){}),
            const Divider(),
            SwitchListTile(title: const Text('Email Notifications'), value: true, onChanged: (v){}),
            const Divider(),
            const ListTile(title: Text('Application Version'), trailing: Text('1.0.0')),
            const ListTile(title: Text('Backend Status'), trailing: Text('Connected', style: TextStyle(color: Colors.green))),
            const ListTile(title: Text('Database Status'), trailing: Text('Connected', style: TextStyle(color: Colors.green))),
          ],
        ),
      ),
    );
  }
}
