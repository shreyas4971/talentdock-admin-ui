import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final List<String> navigationItems;
  final ValueChanged<int> onNavigationItemSelected;
  final int selectedIndex;

  const AppShell({
    super.key,
    required this.child,
    required this.navigationItems,
    required this.onNavigationItemSelected,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Basic responsive shell: Sidebar for web/tablet, BottomNav for mobile
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: isDesktop ? null : AppBar(title: const Text('TalentOS')),
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              destinations: navigationItems.map((item) => NavigationRailDestination(
                icon: const Icon(Icons.circle),
                label: Text(item),
              )).toList(),
              selectedIndex: selectedIndex,
              onDestinationSelected: onNavigationItemSelected,
              extended: true,
            ),
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : BottomNavigationBar(
        items: navigationItems.map((item) => BottomNavigationBarItem(
          icon: const Icon(Icons.circle),
          label: item,
        )).toList(),
        currentIndex: selectedIndex,
        onTap: onNavigationItemSelected,
      ),
    );
  }
}
