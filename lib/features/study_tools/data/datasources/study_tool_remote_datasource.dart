import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:al_zakat_of_knowledge_app/core/utils/supabase_timeout.dart';

import '../models/study_tool_model.dart';

abstract class StudyToolRemoteDataSource {
  Future<List<StudyToolModel>> getStudyTools();
  Future<List<StudyToolModel>> getStudyToolsByOwner(String ownerId);

  Future<StudyToolModel> createStudyTool({
    required String ownerId,
    required String title,
    required String subject,
    required String studyYear,
    required String university,
    required String city,
    required String pickupPlace,
    required String pickupNotes,
    required int categoryId,
    required String kind,
  });

  Future<StudyToolModel> updateStudyTool({
    required String toolId,
    required String title,
    required String subject,
    required String studyYear,
    required String university,
    required String city,
    required String pickupPlace,
    required String pickupNotes,
    required int categoryId,
    required String kind,
  });

  Future<void> deleteStudyTool({required String toolId});
  Future<void> takeStudyTool({required String toolId});
}

class StudyToolRemoteDataSourceImpl implements StudyToolRemoteDataSource {
  final SupabaseClient supabaseClient;

  StudyToolRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<StudyToolModel>> getStudyTools() async {
    final response =
        await (supabaseClient
                .from('materials')
                .select()
                .eq('status', 'active')
                .order('created_at', ascending: false))
            .withTimeout(operationName: 'getStudyTools');
    return response.map((json) => StudyToolModel.fromMap(json)).toList();
  }

  @override
  Future<List<StudyToolModel>> getStudyToolsByOwner(String ownerId) async {
    final response =
        await (supabaseClient
                .from('materials')
                .select()
                .eq('owner_id', ownerId)
                .order('created_at', ascending: false))
            .withTimeout(operationName: 'getStudyToolsByOwner');
    return response.map((json) => StudyToolModel.fromMap(json)).toList();
  }

  @override
  Future<StudyToolModel> createStudyTool({
    required String ownerId,
    required String title,
    required String subject,
    required String studyYear,
    required String university,
    required String city,
    required String pickupPlace,
    required String pickupNotes,
    required int categoryId,
    required String kind,
  }) async {
    final payload = <String, dynamic>{
      'owner_id': ownerId,
      'title': title,
      'subject': subject,
      'study_year': studyYear,
      'university': university,
      'city': city,
      'pickup_place': pickupPlace,
      'pickup_notes': pickupNotes,
      'category_id': categoryId,
      'kind': kind,
    };

    final response = await supabaseClient
        .from('materials')
        .insert(payload)
        .select()
        .maybeSingleWithTimeout(operationName: 'createStudyTool');

    if (response == null) {
      throw Exception('Material creation returned no row');
    }
    return StudyToolModel.fromMap(response);
  }

  @override
  Future<StudyToolModel> updateStudyTool({
    required String toolId,
    required String title,
    required String subject,
    required String studyYear,
    required String university,
    required String city,
    required String pickupPlace,
    required String pickupNotes,
    required int categoryId,
    required String kind,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'subject': subject,
      'study_year': studyYear,
      'university': university,
      'city': city,
      'pickup_place': pickupPlace,
      'pickup_notes': pickupNotes,
      'category_id': categoryId,
      'kind': kind,
    };

    final response = await supabaseClient
        .from('materials')
        .update(payload)
        .eq('id', toolId)
        .select()
        .maybeSingleWithTimeout(operationName: 'updateStudyTool');

    if (response == null) {
      throw Exception('Material update returned no row');
    }
    return StudyToolModel.fromMap(response);
  }

  @override
  Future<void> deleteStudyTool({required String toolId}) async {
    print('<<<<<<<<<<<[deleteStudyTool RPC]>>>>>>>>>>>>>');
    await supabaseClient.rpc(
      'delete_material',
      params: {'p_material_id': toolId},
    );
    print('<<<<<<<<<<<[deleteStudyTool RPC DONE]>>>>>>>>>>>>>');
  }

  @override
  Future<void> takeStudyTool({required String toolId}) async {
    await supabaseClient.rpc(
      'take_material',
      params: {'p_material_id': toolId},
    );
  }
}
