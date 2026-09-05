import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'src/api_client.dart';
import 'src/screens/landing_screen.dart';
import 'src/screens/position_listing_screen.dart';
import 'src/screens/position_details_screen.dart';
import 'src/screens/application_form_screen.dart';
import 'src/screens/success_screen.dart';
import 'src/theme/app_theme.dart';

void main() {
  debugPrint('TalentDock Candidate API: $apiBaseUrl');
  runApp(const ProviderScope(child: CandidateApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/positions',
        builder: (context, state) => const PositionListingScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => PositionDetailsScreen(id: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'apply',
                builder: (context, state) {
                  final step = int.tryParse(state.uri.queryParameters['step'] ?? '0') ?? 0;
                  return ApplicationFormScreen(positionId: state.pathParameters['id']!, initialStep: step);
                },
              ),
            ]
          ),
        ]
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => SuccessScreen(
          refId: state.uri.queryParameters['refId'],
          email: state.uri.queryParameters['email'],
        ),
      ),
    ],
  );
});

class CandidateApp extends ConsumerWidget {
  const CandidateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'TalentDock Careers',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
