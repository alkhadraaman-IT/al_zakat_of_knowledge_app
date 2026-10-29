import 'package:al_zakat_of_knowledge_app/core/errors/failures.dart';
import 'package:al_zakat_of_knowledge_app/core/utils/either.dart';
import 'package:al_zakat_of_knowledge_app/features/study_tools/domain/entities/study_tool_entity.dart';
import 'package:al_zakat_of_knowledge_app/features/study_tools/domain/usecases/create_study_tool_usecase.dart';
import 'package:al_zakat_of_knowledge_app/features/study_tools/domain/usecases/delete_study_tool_usecase.dart';
import 'package:al_zakat_of_knowledge_app/features/study_tools/domain/usecases/get_study_tools_usecase.dart';
import 'package:al_zakat_of_knowledge_app/features/study_tools/domain/usecases/take_study_tool_usecase.dart';
import 'package:al_zakat_of_knowledge_app/features/study_tools/domain/usecases/update_study_tool_usecase.dart';
import 'package:al_zakat_of_knowledge_app/features/study_tools/presentation/cubit/study_tool_cubit.dart';
import 'package:al_zakat_of_knowledge_app/features/study_tools/presentation/cubit/study_tool_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ─── Mocks ──────────────────────────────────────
class MockGetStudyToolsUseCase extends Mock implements GetStudyToolsUseCase {}
class MockCreateStudyToolUseCase extends Mock
    implements CreateStudyToolUseCase {}
class MockUpdateStudyToolUseCase extends Mock
    implements UpdateStudyToolUseCase {}
class MockDeleteStudyToolUseCase extends Mock
    implements DeleteStudyToolUseCase {}
class MockTakeStudyToolUseCase extends Mock implements TakeStudyToolUseCase {}

void main() {
  late MockGetStudyToolsUseCase getTools;
  late MockCreateStudyToolUseCase createTool;
  late MockUpdateStudyToolUseCase updateTool;
  late MockDeleteStudyToolUseCase deleteTool;
  late MockTakeStudyToolUseCase takeTool;

  setUp(() {
    getTools = MockGetStudyToolsUseCase();
    createTool = MockCreateStudyToolUseCase();
    updateTool = MockUpdateStudyToolUseCase();
    deleteTool = MockDeleteStudyToolUseCase();
    takeTool = MockTakeStudyToolUseCase();
  });

  StudyToolCubit buildCubit() => StudyToolCubit(
        getStudyToolsUseCase: getTools,
        createStudyToolUseCase: createTool,
        updateStudyToolUseCase: updateTool,
        deleteStudyToolUseCase: deleteTool,
        takeStudyToolUseCase: takeTool,
      );

  // ✅ fakeTool: بدون const، و createdAt قيمة ثابتة
  final fakeTool = StudyToolEntity(
    id: 't1',
    ownerId: 'u2',
    title: 'كتاب',
    subject: 'رياضيات',
    studyYear: '2024',
    university: 'دمشق',
    city: 'دمشق',
    pickupPlace: 'الجامعة',
    pickupNotes: '',
    categoryId: 1,
    isTaken: false,
    status: 'active',
    kind: 'book',
    createdAt: DateTime(2024, 1, 1),
  );

  // ✅ الاختبار 1: تحميل ناجح
  blocTest<StudyToolCubit, StudyToolState>(
    'يصدر [Loading, Loaded] عند نجاح الجلب',
    build: () {
      when(() => getTools()).thenAnswer((_) async => Right([fakeTool]));
      return buildCubit();
    },
    act: (cubit) => cubit.getStudyTools(),
    expect: () => [
      const StudyToolLoading(),
      StudyToolLoaded(tools: [fakeTool]),
    ],
  );

  // ✅ الاختبار 2: فشل الجلب
  blocTest<StudyToolCubit, StudyToolState>(
    'يصدر [Loading, Error] عند فشل الجلب',
    build: () {
      when(() => getTools()).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'network down')),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.getStudyTools(),
    expect: () => [
      const StudyToolLoading(),
      isA<StudyToolError>()
          .having((e) => e.message, 'message', 'network down'),
    ],
  );
}