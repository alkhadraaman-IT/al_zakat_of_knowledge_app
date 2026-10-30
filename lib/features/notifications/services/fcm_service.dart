import '../data/datasources/pending_messages_data_source.dart';
import '../domain/repositories/notification_scheduler.dart';
import '../domain/usecases/sync_category_topics_usecase.dart';
import 'fcm_token_manager.dart';
import 'foreground_message_listener.dart';
import 'guarded.dart';
import 'pending_messages_drainer.dart';

/// واجهة رفيعة تنسّق الأجزاء: التوكن، الـ topics، الاستماع، طابور الخلفية.
/// (كل جزء منها بملفه، وهذه الفئة بلا منطق خاص بها.)
class FcmService {
  final FcmTokenManager _token;
  final ForegroundMessageListener _foreground;
  final PendingMessagesDrainer _drainer;
  final SyncCategoryTopicsUseCase _topics;
  final NotificationScheduler _scheduler;
  final PendingMessagesDataSource _pending;
  final String? Function() _currentUserId;

  FcmService({
    required FcmTokenManager token,
    required ForegroundMessageListener foreground,
    required PendingMessagesDrainer drainer,
    required SyncCategoryTopicsUseCase topics,
    required NotificationScheduler scheduler,
    required PendingMessagesDataSource pending,
    required String? Function() currentUserId,
  }) : _token = token,
       _foreground = foreground,
       _drainer = drainer,
       _topics = topics,
       _scheduler = scheduler,
       _pending = pending,
       _currentUserId = currentUserId;

  /// تفعيل الإشعارات (تسجيل الدخول).
  /// [followedCategoryIds] == null يعني فشل جلبها: لا نلمس الاشتراكات
  /// (تمرير مجموعة فارغة بالخطأ سيلغي كل اشتراكات المستخدم).
  Future<void> start({Set<String>? followedCategoryIds}) async {
    await _pending.setCurrentUserId(_currentUserId());
    await _token.activate();
    _foreground.start();
    _drainer.start();
    if (followedCategoryIds != null) {
      await guarded('sync topics', () => _topics(followedCategoryIds));
    }
    await guarded('drain pending', _drainer.drain);
  }

  /// إيقاف الإشعارات (تسجيل الخروج): استدعِها قبل signOut.
  Future<void> stop() async {
    // 🔒 أولاً وقبل أي شيء: عطّل معالج الخلفية فوراً.
    // حتى لو استغرق حذف التوكن ثوانٍ على شبكة بطيئة،
    // أي رسالة FCM تصل بعد هذه اللحظة تُتجاهل بلا عرض.
    await _pending.setCurrentUserId(null);

    await _foreground.stop();
    _drainer.stop();
    await guarded('unsubscribe topics', () => _topics(const {}));
    await _token.deactivate();
    await guarded('clear topics', _topics.clear);
    await guarded('cancel alarms', _scheduler.cancelAll);
  }
}
