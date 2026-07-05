import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/dashboard_screen.dart';
import 'src/screens/position_list_screen.dart';
import 'src/screens/position_edit_screen.dart';
import 'src/screens/candidate_list_screen.dart';
import 'src/screens/candidate_details_screen.dart';
import 'src/screens/feedback_list_screen.dart';
import 'src/screens/settings_screen.dart';
void main() {
  runApp(const ProviderScope(child: AdminApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/positions',
        builder: (context, state) => const PositionListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const PositionEditScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => PositionEditScreen(id: state.pathParameters['id']),
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
        path: '/feedback',
        builder: (context, state) => const FeedbackListScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'TalentOS Admin',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: router,
    );
  }
}
