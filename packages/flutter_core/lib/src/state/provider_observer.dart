import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

class TalentProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    developer.log(
      '''
      {
        "provider": "${provider.name ?? provider.runtimeType}",
        "previous": "$previousValue",
        "new": "$newValue"
      }
      ''',
      name: 'TalentProviderObserver',
    );
  }
}
