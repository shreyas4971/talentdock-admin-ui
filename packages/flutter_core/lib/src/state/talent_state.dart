import 'package:flutter/foundation.dart';

sealed class TalentState<T> {
  final DateTime timestamp;
  final String? requestId;
  final bool isOffline;

  const TalentState({
    required this.timestamp,
    this.requestId,
    this.isOffline = false,
  });
}

class TalentStateInitial<T> extends TalentState<T> {
  TalentStateInitial({
    DateTime? timestamp,
    super.requestId,
    super.isOffline,
  }) : super(timestamp: timestamp ?? DateTime.now());
}

class TalentStateLoading<T> extends TalentState<T> {
  TalentStateLoading({
    DateTime? timestamp,
    super.requestId,
    super.isOffline,
  }) : super(timestamp: timestamp ?? DateTime.now());
}

class TalentStateRefreshing<T> extends TalentState<T> {
  final T data;
  
  TalentStateRefreshing(
    this.data, {
    DateTime? timestamp,
    super.requestId,
    super.isOffline,
  }) : super(timestamp: timestamp ?? DateTime.now());
}

class TalentStateSuccess<T> extends TalentState<T> {
  final T data;

  TalentStateSuccess(
    this.data, {
    DateTime? timestamp,
    super.requestId,
    super.isOffline,
  }) : super(timestamp: timestamp ?? DateTime.now());
}

class TalentStateEmpty<T> extends TalentState<T> {
  TalentStateEmpty({
    DateTime? timestamp,
    super.requestId,
    super.isOffline,
  }) : super(timestamp: timestamp ?? DateTime.now());
}

class TalentStateError<T> extends TalentState<T> {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final T? previousData;

  TalentStateError(
    this.message, {
    this.error,
    this.stackTrace,
    this.previousData,
    DateTime? timestamp,
    super.requestId,
    super.isOffline,
  }) : super(timestamp: timestamp ?? DateTime.now());
}
