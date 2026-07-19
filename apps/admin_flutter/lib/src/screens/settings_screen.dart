import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = false;

  void _showChangePasswordDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully.')));
            },
            child: const Text('Save'),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 600,
          child: ListView(
            padding: const EdgeInsets.all(32),
            children: [
              const Text('System Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const ListTile(title: Text('App Version'), trailing: Text('v1.0.2')),
              const ListTile(title: Text('Backend Status'), trailing: Text('Online', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              const ListTile(title: Text('Database Status'), trailing: Text('Connected', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              const ListTile(title: Text('Storage Status'), trailing: Text('Connected', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              const Divider(height: 32),
              const Text('Preferences', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle the application theme.'),
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              const Divider(height: 32),
              const Text('Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Change Password'),
                subtitle: const Text('Update your login credentials.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showChangePasswordDialog,
              ),
              ListTile(
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                trailing: const Icon(Icons.logout, color: Colors.red),
                onTap: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
