import os

base_dir = r"c:\Users\shrey\OneDrive\Desktop\TalentDock\talentos\apps\admin_flutter\lib"
src_dir = os.path.join(base_dir, "src")
dirs = [
    "layout",
    "widgets",
    "screens",
    "screens/positions",
    "screens/candidates",
    "screens/calendar",
    "screens/templates",
    "screens/settings",
]

for d in dirs:
    os.makedirs(os.path.join(src_dir, d), exist_ok=True)

files = {}

files["main.dart"] = """
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'src/layout/admin_layout.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/dashboard_screen.dart';
import 'src/screens/positions/position_list_screen.dart';
import 'src/screens/positions/position_editor_screen.dart';
import 'src/screens/candidates/candidate_list_screen.dart';
import 'src/screens/candidates/candidate_details_screen.dart';
import 'src/screens/calendar/calendar_screen.dart';
import 'src/screens/templates/templates_screen.dart';
import 'src/screens/settings/settings_screen.dart';

void main() {
  runApp(const AdminApp());
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AdminLayout(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/positions',
          builder: (context, state) => const PositionListScreen(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const PositionEditorScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => PositionEditorScreen(id: state.pathParameters['id']),
            ),
          ]
        ),
        GoRoute(
          path: '/candidates',
          builder: (context, state) => const CandidateListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => CandidateDetailsScreen(id: state.pathParameters['id']!),
            ),
          ]
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/templates',
          builder: (context, state) => const TemplatesScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ]
    )
  ],
);

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TalentDock Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F7FA),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black12,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        )
      ),
      routerConfig: router,
    );
  }
}
"""

files["src/mock_data.dart"] = """
final mockPositions = [
  {'id': 'pos-001', 'title': 'Flutter Developer', 'department': 'Engineering', 'location': 'Remote', 'type': 'Full Time', 'experience': '2-4 Years', 'status': 'Published', 'applications': 14},
  {'id': 'pos-002', 'title': 'Product Designer', 'department': 'Design', 'location': 'New York', 'type': 'Contract', 'experience': '5+ Years', 'status': 'Published', 'applications': 8},
  {'id': 'pos-003', 'title': 'Embedded Engineer', 'department': 'Hardware', 'location': 'San Francisco', 'type': 'Full Time', 'experience': '3-5 Years', 'status': 'Draft', 'applications': 0},
];

final mockCandidates = [
  {'id': 'can-001', 'name': 'John Doe', 'position': 'Flutter Developer', 'location': 'Chicago, IL', 'experience': '3 Years', 'notice': '30 Days', 'status': 'Review', 'date': 'Today'},
  {'id': 'can-002', 'name': 'Jane Smith', 'position': 'Product Designer', 'location': 'New York, NY', 'experience': '6 Years', 'notice': '15 Days', 'status': 'Interview', 'date': 'Yesterday'},
  {'id': 'can-003', 'name': 'Michael Chen', 'position': 'Flutter Developer', 'location': 'Remote', 'experience': '2 Years', 'notice': 'Immediate', 'status': 'Applied', 'date': '2 days ago'},
];
"""

files["src/widgets/page_container.dart"] = """
import 'package:flutter/material.dart';

class PageContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  const PageContainer({super.key, required this.child, this.maxWidth = 1200, this.padding = const EdgeInsets.all(32)});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(24),
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 12))
            ]
          ),
          child: child,
        ),
      ),
    );
  }
}
"""

files["src/layout/admin_layout.dart"] = """
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('TalentDock Admin'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(backgroundColor: Colors.blueAccent, child: Text('A', style: TextStyle(color: Colors.white))),
          )
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.white,
            child: ListView(
              children: [
                _NavItem(title: 'Dashboard', icon: Icons.dashboard, route: '/', currentPath: path),
                _NavItem(title: 'Positions', icon: Icons.work, route: '/positions', currentPath: path),
                _NavItem(title: 'Candidates', icon: Icons.people, route: '/candidates', currentPath: path),
                _NavItem(title: 'Calendar', icon: Icons.calendar_month, route: '/calendar', currentPath: path),
                _NavItem(title: 'Templates', icon: Icons.file_copy, route: '/templates', currentPath: path),
                _NavItem(title: 'Settings', icon: Icons.settings, route: '/settings', currentPath: path),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: child),
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
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.blueAccent : Colors.black54),
      title: Text(title, style: TextStyle(color: isActive ? Colors.blueAccent : Colors.black87, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      selected: isActive,
      selectedTileColor: Colors.blueAccent.withOpacity(0.05),
      onTap: () => context.go(route),
    );
  }
}
"""

files["src/screens/login_screen.dart"] = """
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/page_container.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageContainer(
        maxWidth: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.work_outline, size: 64, color: Colors.blueAccent),
            const SizedBox(height: 24),
            const Text('Welcome back to TalentDock', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            TextField(decoration: InputDecoration(labelText: 'Email Address')),
            const SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
              child: const Text('Login'),
            )
          ],
        ),
      ),
    );
  }
}
"""

files["src/screens/dashboard_screen.dart"] = """
import 'package:flutter/material.dart';
import '../widgets/page_container.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              shrinkWrap: true,
              childAspectRatio: 2.5,
              children: [
                _StatCard('Open Positions', '12', Icons.work),
                _StatCard('Applications Today', '28', Icons.today),
                _StatCard('Applications This Week', '145', Icons.calendar_view_week),
                _StatCard('Pending Review', '42', Icons.pending_actions),
                _StatCard('Interviews Today', '5', Icons.video_call),
                _StatCard('Immediate Joiners', '18', Icons.flash_on),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent Applications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Position')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Time')),
                        ],
                        rows: const [
                          DataRow(cells: [DataCell(Text('Alex Turner')), DataCell(Text('Flutter Dev')), DataCell(Text('Review')), DataCell(Text('10 mins ago'))]),
                          DataRow(cells: [DataCell(Text('Sara Lee')), DataCell(Text('Designer')), DataCell(Text('Applied')), DataCell(Text('1 hr ago'))]),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Upcoming Interviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: const Text('John Doe - Flutter Dev'),
                        subtitle: const Text('Today, 2:00 PM'),
                      ),
                      ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: const Text('Jane Smith - Designer'),
                        subtitle: const Text('Tomorrow, 11:00 AM'),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 48),
            const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              children: [
                ActionChip(label: const Text('Create Position'), avatar: const Icon(Icons.add), onPressed: (){}),
                ActionChip(label: const Text('View Candidates'), avatar: const Icon(Icons.people), onPressed: (){}),
                ActionChip(label: const Text('Calendar'), avatar: const Icon(Icons.calendar_today), onPressed: (){}),
                ActionChip(label: const Text('Templates'), avatar: const Icon(Icons.file_copy), onPressed: (){}),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;

  const _StatCard(this.title, this.count, this.icon);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.blueAccent, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Text(title, style: TextStyle(color: Colors.grey.shade600)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
"""

files["src/screens/positions/position_list_screen.dart"] = r"""
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/page_container.dart';
import '../../mock_data.dart';

class PositionListScreen extends StatelessWidget {
  const PositionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Positions', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => context.go('/positions/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('New Position'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search positions...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(icon: const Icon(Icons.filter_list), onPressed: (){}),
              ],
            ),
            const SizedBox(height: 32),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockPositions.length,
              itemBuilder: (context, index) {
                final pos = mockPositions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    title: Text(pos['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Padding(
                      padding: const EdgeInsets.top(8.0),
                      child: Row(
                        children: [
                          _Badge(pos['department'] as String),
                          const SizedBox(width: 8),
                          _Badge(pos['location'] as String),
                          const SizedBox(width: 8),
                          _Badge(pos['type'] as String),
                          const SizedBox(width: 8),
                          Text('• ${pos['experience']} • ${pos['applications']} Apps'),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(label: Text(pos['status'] as String), backgroundColor: pos['status'] == 'Published' ? Colors.green.shade50 : Colors.grey.shade100),
                        const SizedBox(width: 16),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'view', child: Text('View Candidates')),
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'dup', child: Text('Duplicate')),
                            const PopupMenuItem(value: 'archive', child: Text('Archive')),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: Colors.blue.shade700, fontSize: 12)),
    );
  }
}
"""

files["src/screens/positions/position_editor_screen.dart"] = """
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/page_container.dart';

class PositionEditorScreen extends StatefulWidget {
  final String? id;
  const PositionEditorScreen({super.key, this.id});

  @override
  State<PositionEditorScreen> createState() => _PositionEditorScreenState();
}

class _PositionEditorScreenState extends State<PositionEditorScreen> {
  final List<String> specs = ['Flutter', 'Riverpod', 'REST API'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                const SizedBox(width: 16),
                Text(widget.id == null ? 'Create Position' : 'Edit Position', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 32),
            _buildSection('Section 1: Basic Information', [
              Row(children: [Expanded(child: _field('Job Title *')), const SizedBox(width: 16), Expanded(child: _field('Department'))]),
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(decoration: const InputDecoration(labelText: 'Employment Type'), items: const [], onChanged: (v){})),
                const SizedBox(width: 16),
                Expanded(child: _field('Location')),
              ]),
              Row(children: [Expanded(child: _field('Number of Openings')), const SizedBox(width: 16), Expanded(child: DropdownButtonFormField<String>(decoration: const InputDecoration(labelText: 'Status'), items: const [], onChanged: (v){}))]),
            ]),
            _buildSection('Section 2: Candidate Requirements', [
              Row(children: [Expanded(child: _field('Minimum Experience (Years)')), const SizedBox(width: 16), Expanded(child: _field('Maximum Experience (Years)'))]),
              Row(children: [Expanded(child: _field('Relevant Experience Required (e.g. Flutter: 2+)')), const SizedBox(width: 16), Expanded(child: DropdownButtonFormField<String>(decoration: const InputDecoration(labelText: 'Maximum Notice Period'), items: const [], onChanged: (v){}))]),
            ]),
            _buildSection('Section 3: Important Specifications', [
              const Text('Enter keywords/skills to filter candidates.'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: specs.map((s) => Chip(label: Text(s), onDeleted: (){})).toList()..add(ActionChip(label: const Text('Add Spec'), onPressed: (){})),
              )
            ]),
            _buildSection('Section 4: Job Description', [
              TextField(maxLines: 10, decoration: const InputDecoration(hintText: 'Paste Job Description here...')),
            ]),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
                const SizedBox(width: 16),
                OutlinedButton(onPressed: (){}, child: const Text('Save Draft')),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: () => context.pop(), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white), child: const Text('Publish')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          const SizedBox(height: 16),
          for (var child in children) Padding(padding: const EdgeInsets.only(bottom: 16), child: child),
        ],
      ),
    );
  }

  Widget _field(String label) => TextField(decoration: InputDecoration(labelText: label));
}
"""

files["src/screens/candidates/candidate_list_screen.dart"] = r"""
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/page_container.dart';
import '../../mock_data.dart';

class CandidateListScreen extends StatelessWidget {
  const CandidateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Candidates', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search by Name, Email, Phone, Application ID...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(icon: const Icon(Icons.filter_list), label: const Text('Filters'), onPressed: (){}),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Position')),
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('Experience')),
                  DataColumn(label: Text('Notice')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Date')),
                ],
                rows: mockCandidates.map((c) => DataRow(
                  onSelectChanged: (_) => context.go('/candidates/${c['id']}'),
                  cells: [
                    DataCell(Text(c['name']!)),
                    DataCell(Text(c['position']!)),
                    DataCell(Text(c['location']!)),
                    DataCell(Text(c['experience']!)),
                    DataCell(Text(c['notice']!)),
                    DataCell(Chip(label: Text(c['status']!))),
                    DataCell(Text(c['date']!)),
                  ]
                )).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
"""

files["src/screens/candidates/candidate_details_screen.dart"] = r"""
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/page_container.dart';

class CandidateDetailsScreen extends StatelessWidget {
  final String id;
  const CandidateDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                const SizedBox(width: 16),
                const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 32)),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('John Doe', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Flutter Developer • Application ID: APP-10023', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    ],
                  ),
                ),
                Chip(label: const Text('Review', style: TextStyle(color: Colors.white)), backgroundColor: Colors.orange),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: (){}, child: const Text('Change Status')),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCard('Personal Information', [
                        _info('Email', 'john.doe@example.com'),
                        _info('Phone', '+1 555-0198'),
                        _info('Location', 'Chicago, IL'),
                      ]),
                      const SizedBox(height: 24),
                      _buildCard('Career Information', [
                        _info('Highest Education', 'Bachelor\'s Degree'),
                        _info('Employment Status', 'Experienced'),
                        _info('Current Company', 'TechCorp'),
                        _info('Total Experience', '3 Years'),
                        _info('Notice Period', '30 Days'),
                        _info('Expected Salary', '\$120k'),
                      ]),
                      const SizedBox(height: 24),
                      _buildCard('Resume', [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                              const SizedBox(width: 16),
                              const Expanded(child: Text('John_Doe_Resume.pdf', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                              OutlinedButton(onPressed: (){}, child: const Text('Preview')),
                              const SizedBox(width: 8),
                              ElevatedButton(onPressed: (){}, child: const Text('Download')),
                            ],
                          ),
                        )
                      ])
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCard('Recruiter Notes', [
                        TextField(decoration: const InputDecoration(hintText: 'Add a note...'), maxLines: 2),
                        const SizedBox(height: 8),
                        Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: (){}, child: const Text('Save Note'))),
                        const Divider(height: 32),
                        const ListTile(title: Text('Strong technical skills, fits the budget.'), subtitle: Text('Today, 10:30 AM')),
                      ]),
                      const SizedBox(height: 24),
                      _buildCard('Timeline', [
                        _timelineItem('Interview Scheduled', 'Yesterday'),
                        _timelineItem('Status changed to Review', '2 Days ago'),
                        _timelineItem('Application Submitted', '3 Days ago'),
                      ])
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...children
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _timelineItem(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 12, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(child: Text(text)),
          Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }
}
"""

files["src/screens/calendar/calendar_screen.dart"] = """
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widgets/page_container.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Calendar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TableCalendar(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
              headerStyle: const HeaderStyle(formatButtonVisible: false),
            ),
          ],
        ),
      ),
    );
  }
}
"""

files["src/screens/templates/templates_screen.dart"] = """
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
"""

files["src/screens/settings/settings_screen.dart"] = """
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
"""

for path, content in files.items():
    with open(os.path.join(base_dir, path), "w", encoding="utf-8") as f:
        f.write(content)

print("Scaffold complete.")
