import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _emailNotifications = true;
  bool _darkMode = false;

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
              const Text('Personal Preferences', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              SwitchListTile(
                title: const Text('Email Notifications'),
                subtitle: const Text('Receive an email when a new candidate applies.'),
                value: _emailNotifications,
                onChanged: (v) => setState(() => _emailNotifications = v),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle the application theme.'),
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              const Divider(),
              ListTile(
                title: const Text('Change Password'),
                subtitle: const Text('Update your login credentials.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password change not implemented in MVP.')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
