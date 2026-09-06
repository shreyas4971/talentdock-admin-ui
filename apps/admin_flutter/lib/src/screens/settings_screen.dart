import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';
import '../widgets/page_container.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isChangingPassword = false;
  String? _passwordError;
  String? _passwordSuccess;

  Map<String, dynamic>? _liveUserProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final client = ref.read(adminApiClientProvider);
      final profile = await client.getMe();
      if (mounted) {
        setState(() {
          _liveUserProfile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _handleChangePassword() async {
    setState(() {
      _passwordError = null;
      _passwordSuccess = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final currentPass = _currentPasswordCtrl.text;
    final newPass = _newPasswordCtrl.text;
    final confirmPass = _confirmPasswordCtrl.text;

    if (newPass != confirmPass) {
      setState(() => _passwordError = 'New password and confirmation do not match.');
      return;
    }

    setState(() => _isChangingPassword = true);

    try {
      final client = ref.read(adminApiClientProvider);
      await client.changePassword(
        currentPassword: currentPass,
        newPassword: newPass,
        confirmPassword: confirmPass,
      );

      if (mounted) {
        setState(() {
          _isChangingPassword = false;
          _passwordSuccess = 'Password changed successfully.';
          _currentPasswordCtrl.clear();
          _newPasswordCtrl.clear();
          _confirmPasswordCtrl.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
          _passwordError = getFriendlyErrorMessage(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionUser = ref.watch(authUserProvider);
    final email = _liveUserProfile?['email'] ?? sessionUser?['email'] ?? 'admin@talentdock.com';
    final name = _liveUserProfile?['name'] ?? sessionUser?['name'] ?? 'TalentDock Admin';
    final role = _liveUserProfile?['role'] ?? sessionUser?['role'] ?? 'ADMIN';

    return SingleChildScrollView(
      child: PageContainer(
        maxWidth: 800,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back to Dashboard',
                  onPressed: () => context.go('/'),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Account Settings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Card 1: Account Information
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue.shade50,
                        child: Text(
                          (name.toString().isNotEmpty ? name.toString()[0] : 'A').toUpperCase(),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.toString(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              role.toString().toUpperCase(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Admin Name', value: name.toString()),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Email Address', value: email.toString()),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Role', value: role.toString()),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Card 2: Security & Change Password
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Security',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Update your admin password below. Ensure it is at least 6 characters.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),

                    if (_passwordSuccess != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _passwordSuccess!,
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_passwordError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _passwordError!,
                                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Current Password
                    TextFormField(
                      controller: _currentPasswordCtrl,
                      obscureText: _obscureCurrent,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // New Password
                    TextFormField(
                      controller: _newPasswordCtrl,
                      obscureText: _obscureNew,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.trim().length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm New Password
                    TextFormField(
                      controller: _confirmPasswordCtrl,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordCtrl.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Change Password Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _isChangingPassword ? null : _handleChangePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isChangingPassword
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
