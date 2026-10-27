/// الحد الأدنى من بيانات الجلسة اللازمة لجدولة التنبيهات المحلية.
/// (كيان خاص بميزة الإشعارات كي لا نرتبط بميزة الجلسات.)
class SessionSchedule {
  final String sessionId;
  final String title;
  final DateTime startsAt;
  final DateTime endsAt;

  const SessionSchedule({
    required this.sessionId,
    required this.title,
    required this.startsAt,
    required this.endsAt,
  });
}
