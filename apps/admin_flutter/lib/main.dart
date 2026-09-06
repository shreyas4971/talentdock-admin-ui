import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/api_client.dart';
import 'src/layout/admin_layout.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/dashboard_screen.dart';
import 'src/screens/positions/position_list_screen.dart';
import 'src/screens/positions/position_editor_screen.dart';
import 'src/screens/candidate_list_screen.dart';
import 'src/screens/candidate_details_screen.dart';
import 'src/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const AdminApp(),
  ));
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final token = ref.watch(authTokenProvider);
  final isMock = apiBaseUrl.isEmpty;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggingIn = state.uri.path == '/login';
      // In production mode, if not authenticated, force /login
      if (!isMock && token == null) {
        return isLoggingIn ? null : '/login';
      }
      // If already logged in and at /login, redirect to /
      if (token != null && isLoggingIn) {
        return '/';
      }
      return null;
    },
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
            ],
          ),
          GoRoute(
            path: '/candidates',
            builder: (context, state) => const CandidateListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => CandidateDetailsScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
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
      title: 'TalentDock Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Layer 1
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black12,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Layer 3 cards
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
      routerConfig: router,
    );
  }
}
