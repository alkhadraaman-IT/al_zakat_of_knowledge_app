import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_timeouts.dart';

/// Exception thrown when a Supabase call times out.
class SupabaseTimeoutException implements Exception {
  final String operationName;
  final Duration timeout;

  SupabaseTimeoutException(this.operationName, this.timeout);

  @override
  String toString() =>
      'SupabaseTimeoutException: $operationName timed out after ${timeout.inSeconds}s';
}

/// Exception thrown when a network socket error occurs.
class SupabaseSocketException implements Exception {
  final String message;
  final int? osErrorCode;

  SupabaseSocketException(this.message, {this.osErrorCode});

  @override
  String toString() => 'SupabaseSocketException: $message';
}

/// Utility for applying strict timeouts to Supabase client calls
/// and converting timeout/connection errors into typed exceptions
/// that can be caught by the existing repository error handling.
extension SupabaseTimeoutExtension<T> on Future<T> {
  /// Applies a timeout and throws typed exceptions for
  /// timeout/connection errors.
  Future<T> withTimeout({
    Duration? timeout,
    String? operationName,
  }) async {
    final effectiveTimeout = timeout ?? AppTimeouts.call;
    try {
      return await this.timeout(effectiveTimeout);
    } on TimeoutException {
      print('<<<<<<<<<<<[Timeout]>>>>>>>>>>>>>');
      print('Operation timed out: ${operationName ?? 'unknown'} after ${effectiveTimeout.inSeconds}s');
      throw SupabaseTimeoutException(operationName ?? 'unknown', effectiveTimeout);
    } on SocketException catch (e) {
      print('<<<<<<<<<<<[SocketException]>>>>>>>>>>>>>');
      print('Socket error: ${e.message} (OS error: ${e.osError?.errorCode})');
      throw SupabaseSocketException(e.message, osErrorCode: e.osError?.errorCode);
    } on HttpException catch (e) {
      print('<<<<<<<<<<<[HttpException]>>>>>>>>>>>>>');
      print('HTTP error: ${e.message}');
      throw Exception('HTTP error: ${e.message}');
    }
  }

  /// Applies a timeout for auth operations.
  Future<T> withAuthTimeout({
    Duration? timeout,
    String? operationName,
  }) async {
    final effectiveTimeout = timeout ?? AppTimeouts.call;
    try {
      return await this.timeout(effectiveTimeout);
    } on TimeoutException {
      print('<<<<<<<<<<<[Timeout]>>>>>>>>>>>>>');
      print('Operation timed out: ${operationName ?? 'auth'} after ${effectiveTimeout.inSeconds}s');
      throw SupabaseTimeoutException(operationName ?? 'auth', effectiveTimeout);
    } on SocketException catch (e) {
      print('<<<<<<<<<<<[SocketException]>>>>>>>>>>>>>');
      print('Socket error: ${e.message} (OS error: ${e.osError?.errorCode})');
      throw SupabaseSocketException(e.message, osErrorCode: e.osError?.errorCode);
    } on HttpException catch (e) {
      print('<<<<<<<<<<<[HttpException]>>>>>>>>>>>>>');
      print('HTTP error: ${e.message}');
      throw Exception('HTTP error: ${e.message}');
    }
  }

  /// Applies a timeout for storage operations.
  Future<T> withStorageTimeout({
    Duration? timeout,
    String? operationName,
  }) async {
    final effectiveTimeout = timeout ?? AppTimeouts.storageUpload;
    try {
      return await this.timeout(effectiveTimeout);
    } on TimeoutException {
      print('<<<<<<<<<<<[Timeout]>>>>>>>>>>>>>');
      print('Operation timed out: ${operationName ?? 'storage'} after ${effectiveTimeout.inSeconds}s');
      throw SupabaseTimeoutException(operationName ?? 'storage', effectiveTimeout);
    } on SocketException catch (e) {
      print('<<<<<<<<<<<[SocketException]>>>>>>>>>>>>>');
      print('Socket error: ${e.message} (OS error: ${e.osError?.errorCode})');
      throw SupabaseSocketException(e.message, osErrorCode: e.osError?.errorCode);
    } on HttpException catch (e) {
      print('<<<<<<<<<<<[HttpException]>>>>>>>>>>>>>');
      print('HTTP error: ${e.message}');
      throw Exception('HTTP error: ${e.message}');
    }
  }
}

// Extension for PostgrestTransformBuilder (insert/update/delete operations)
extension PostgrestTransformTimeoutExtension on PostgrestTransformBuilder {
  /// Applies a timeout to maybeSingle.
  Future<dynamic> maybeSingleWithTimeout({
    Duration? timeout,
    String? operationName,
  }) async {
    final effectiveTimeout = timeout ?? AppTimeouts.call;
    try {
      return await this.maybeSingle().timeout(effectiveTimeout);
    } on TimeoutException {
      print('<<<<<<<<<<<[Timeout]>>>>>>>>>>>>>');
      print('Operation timed out: ${operationName ?? 'maybeSingle'} after ${effectiveTimeout.inSeconds}s');
      throw SupabaseTimeoutException(operationName ?? 'maybeSingle', effectiveTimeout);
    } on SocketException catch (e) {
      print('<<<<<<<<<<<[SocketException]>>>>>>>>>>>>>');
      print('Socket error: ${e.message} (OS error: ${e.osError?.errorCode})');
      throw SupabaseSocketException(e.message, osErrorCode: e.osError?.errorCode);
    } on HttpException catch (e) {
      print('<<<<<<<<<<<[HttpException]>>>>>>>>>>>>>');
      print('HTTP error: ${e.message}');
      throw Exception('HTTP error: ${e.message}');
    }
  }
}