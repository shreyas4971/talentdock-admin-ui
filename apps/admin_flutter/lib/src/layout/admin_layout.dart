
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../api_client.dart';

class AdminLayout extends ConsumerWidget {
  final Widget child;
  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final authUser = ref.watch(authUserProvider);
    final userEmail = authUser?['email'] as String? ?? 'admin@talentdock.com';
    final userName = authUser?['name'] as String? ?? 'Admin User';
    final userInitial = (userName.isNotEmpty ? userName[0] : (userEmail.isNotEmpty ? userEmail[0] : 'A')).toUpperCase();

    final sidebar = Container(
      width: 280,
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          _NavItem(title: 'Dashboard', icon: Icons.dashboard, route: '/', currentPath: path),
          _NavItem(title: 'Positions', icon: Icons.work, route: '/positions', currentPath: path),
          _NavItem(title: 'Candidates', icon: Icons.people, route: '/candidates', currentPath: path),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('TalentDock Admin'),
        leading: isDesktop ? null : Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search dialog opened')));
          }),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications opened')));
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tooltip: 'Account Details',
              onSelected: (value) {
                if (value == 'logout') {
                  ref.read(authTokenProvider.notifier).setToken(null);
                  ref.read(authUserProvider.notifier).setUser(null);
                  context.go('/login');
                } else if (value == 'settings') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings opened')));
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text(userEmail, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20),
                      SizedBox(width: 12),
                      Text('Account Settings'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(userInitial, style: const TextStyle(color: Colors.white)),
              ),
            ),
          )
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: sidebar),
      body: Row(
        children: [
          if (isDesktop) sidebar,
          if (isDesktop) const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F7FA), // Layer 1
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 1400),
                  margin: EdgeInsets.all(isDesktop ? 24 : 16),
                  padding: EdgeInsets.all(isDesktop ? 32 : 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF), // Layer 2
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black12.withValues(alpha: 0.04), blurRadius: 40, offset: const Offset(0, 12))
                    ]
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;
  final String currentPath;

  const _NavItem({required this.title, required this.icon, required this.route, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final isActive = route == '/' ? currentPath == '/' : currentPath.startsWith(route);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Icon(icon, color: isActive ? Colors.white : Colors.black54),
          title: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.black87, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          selected: isActive,
          onTap: () {
            if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
              Navigator.pop(context);
            }
            context.go(route);
          },
        ),
      ),
    );
  }
}
