import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'src/screens/position_listing_screen.dart';
import 'src/screens/position_details_screen.dart';
import 'src/screens/application_form_screen.dart';
import 'src/screens/success_screen.dart';

void main() {
  runApp(const ProviderScope(child: CandidateApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PositionListingScreen(),
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => SuccessScreen(refId: state.uri.queryParameters['refId']),
      ),
      GoRoute(
        path: '/positions/:id',
        builder: (context, state) => PositionDetailsScreen(id: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'apply',
            builder: (context, state) => ApplicationFormScreen(positionId: state.pathParameters['id']!),
          ),
        ]
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
      title: 'TalentOS Careers',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      routerConfig: router,
    );
  }
}
