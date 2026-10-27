import '../data/datasources/incoming_message_bus.dart';
import '../data/models/incoming_message_parser.dart';
import '../domain/entities/notification_behavior.dart';
import '../domain/usecases/handle_incoming_notification_usecase.dart';
import 'guarded.dart';

/// مسار معالجة واحد لأي رسالة FCM (من التطبيق المفتوح أو من طابور الخلفية):
/// تحليل ← تجاهل (لا مستخدم / ناشر المحتوى نفسه) ← معالجة حسب سلوك النوع
/// ← إعلام الواجهة بالتحديث ← شريط مرئي (للتطبيق المفتوح فقط).
class IncomingMessagePipeline {
  final HandleIncomingNotificationUseCase _handle;
  final IncomingMessageBus _bus;
  final String? Function() _currentUserId;

  IncomingMessagePipeline({
    required HandleIncomingNotificationUseCase handle,
    required IncomingMessageBus bus,
    required String? Function() currentUserId,
  })  : _handle = handle,
        _bus = bus,
        _currentUserId = currentUserId;

  Future<void> process(Map<String, dynamic> data, {required bool fromForeground}) async {
    final uid = _currentUserId();
    if (uid == null) return; // لا مستخدم مسجّل: لا نعالج شيئاً

    final m = IncomingMessageParser.tryParse(data);
    if (m == null) return;
    if (m.publisherId != null && m.publisherId == uid) return;

    await guarded('handle ${m.type.value}', () => _handle(m));
    _bus.notifyChanged(); // القائمة المفتوحة تتحدث تلقائياً

    // بالخلفية عُرض تنبيه النظام سابقاً، فلا شريط داخل التطبيق
    if (fromForeground && m.type.behavior.showInAppBanner) _bus.showBanner(m);
  }
}
