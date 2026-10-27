import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:al_zakat_of_knowledge_app/core/utils/supabase_timeout.dart';
import '../../domain/entities/report_entity.dart';

/// Abstract remote data source for reports.
abstract class ReportRemoteDataSource {
  /// Submits a new report to the `reports` table.
  Future<ReportEntity> createReport({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  });
}

/// Supabase implementation of [ReportRemoteDataSource].
class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final SupabaseClient supabaseClient;

  ReportRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<ReportEntity> createReport({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
  }) async {
    print('<<<<<<<<<<<[createReport]>>>>>>>>>>>>>');
    final owner = supabaseClient.auth.currentUser!.id;
    if (owner != reporterId) {
      throw Exception('Reporter ID mismatch: reporter must be the current user');
    }

    final report = ReportEntity(
      id: '',
      reporterId: reporterId,
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      details: details,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    // Log the exact insert payload being sent to the `reports` table.
    final payload = report.toInsertJson();
    print('<<<<<<<<<<<[createReport Payload]>>>>>>>>>>>>>');
    print('Payload: $payload');

    try {
      final response = await supabaseClient
          .from('reports')
          .insert(payload)
          .select()
          .maybeSingleWithTimeout(operationName: 'createReport');

      if (response == null) {
        throw Exception('Report creation returned no row');
      }

      return ReportEntity.fromSupabase(response);
    } on PostgrestException catch (e) {
      // Detailed logging — exposes the exact Postgrest error (code, message, details, hint) for tracing.
      print('<<<<<<<<<<<[createReport PostgrestException]>>>>>>>>>>>>>');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('Details: ${e.details}');
      print('Hint: ${e.hint}');
      rethrow;
    } catch (e) {
      // Detailed logging — exposes missing or mismatched insert fields (RLS, schema drift) for tracing.
      print('<<<<<<<<<<<[createReport Error]>>>>>>>>>>>>>');
      print('Exception: $e');
      rethrow;
    }
  }
}