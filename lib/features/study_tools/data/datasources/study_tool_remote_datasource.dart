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
}

class StudyToolRemoteDataSourceImpl implements StudyToolRemoteDataSource {
  final SupabaseClient supabaseClient;

  StudyToolRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<StudyToolModel>> getStudyTools() async {
    print('<<<<<<<<<<<[getStudyTools]>>>>>>>>>>>>>');
    final response = await (supabaseClient
        .from('materials')
        .select()
        .order('created_at', ascending: false))
        .withTimeout(operationName: 'getStudyTools');
    
    // التصحيح هنا: استخدام fromMap بدلاً من fromEntity
    return response
        .map((json) => StudyToolModel.fromMap(json))
        .toList();
  }

  @override
  Future<List<StudyToolModel>> getStudyToolsByOwner(String ownerId) async {
    print('<<<<<<<<<<<[getStudyToolsByOwner]>>>>>>>>>>>>>');
    final response = await (supabaseClient
        .from('materials')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false))
        .withTimeout(operationName: 'getStudyToolsByOwner');
    
    // التصحيح هنا: استخدام fromMap بدلاً من fromEntity
    return response
        .map((json) => StudyToolModel.fromMap(json))
        .toList();
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
    print('<<<<<<<<<<<[createStudyTool]>>>>>>>>>>>>>');
    final material = StudyToolModel(
      id: '',
      ownerId: ownerId,
      title: title,
      subject: subject,
      studyYear: studyYear,
      university: university,
      city: city,
      pickupPlace: pickupPlace,
      pickupNotes: pickupNotes,
      categoryId: categoryId,
      isTaken: false,
      status: 'available',
      kind: kind,
      createdAt: DateTime.now(),
    );

    final payload = material.toInsertJson();
    print('<<<<<<<<<<<[createStudyTool Payload]>>>>>>>>>>>>>');
    print('Payload: $payload');

    try {
      final response = await supabaseClient
          .from('materials')
          .insert(payload)
          .select()
          .maybeSingleWithTimeout(operationName: 'createStudyTool');

      if (response == null) {
        throw Exception('Material creation returned no row');
      }

      print('Status: 201 Created');
      
      // التصحيح هنا: استخدام fromMap بدلاً من fromEntity
      return StudyToolModel.fromMap(response);
    } on PostgrestException catch (e) {
      print('<<<<<<<<<<<[createStudyTool PostgrestException]>>>>>>>>>>>>>');
      print('Code: ${e.code}');
      print('Message: ${e.message}');
      print('Details: ${e.details}');
      print('Hint: ${e.hint}');
      rethrow;
    } catch (e) {
      print('<<<<<<<<<<<[createStudyTool Error]>>>>>>>>>>>>>');
      print('Exception: $e');
      rethrow;
    }
  }
}