# زكاة العلم 📖

تطبيق أكاديمي مجتمعي لطلاب الجامعات، مبني بـ Flutter، يساعد الطلاب على الوصول للمحاضرات والمقالات العلمية، حجز المحاضرات عبر QR، والتنقل إليها عبر الخريطة، مع دعم كامل للعمل بدون إنترنت.

## 💡 فكرة المشروع

يهدف زكاة العلم إلى نشر المعرفة الأكاديمية بين طلاب الجامعات من خلال تطبيق عصري يجمع بين المحتوى العلمي، والمحاضرات، وأدوات الدراسة، مع تجربة سلسة تدعم العربية والـ RTL والعمل بدون اتصال.

---

## 🚀 التقنيات المستخدمة (Tech Stack)

- التقنية الأساسية: [Flutter](https://flutter.dev/) (Dart SDK ^3.13.1)
- إدارة الحالة: flutter_bloc + Equatable
- حقن التبعيات: GetIt
- المصادقة وقاعدة البيانات: [Supabase](https://supabase.com/) (Auth + Database + Storage)
- الإشعارات الفورية: Firebase Messaging

---

## ✨ المميزات الرئيسية

- 🔍 البحث داخل المحتوى العلمي والمقالات.
- ⭐ المفضلة لحفظ المحاضرات والمقالات.
- 📅 حجز المحاضرات ومشاركتها عبر QR Code.
- 🗺️ الخرائط لعرض مواقع المحاضرات والتنقل إليها.
- 📄 عرض ملفات PDF داخل التطبيق للمقالات.
- 🔔 إشعارات فورية + مجدولة (تذكير بموعد المحاضرة).
- 📴 العمل بدون إنترنت عبر تخزين مؤقت محلي.
- 🌐 تعدد اللغات ودعم RTL بشكل كامل.

---

## 📦 أهم المكتبات المستخدمة

### 🧠 إدارة الحالة — flutter_bloc + equatable

نمط BLoC بيفصل منطق العمل تمامًا عن الواجهة، عبر Event → Bloc → State. مكتبة equatable بتساعد بمقارنة الـ States بسرعة لتجنب إعادة بناء الواجهة بدون داعٍ.

بالمشروع: كل شاشة رئيسية (المحاضرات، الحجز، المفضلة) لها Bloc مستقل.

---

### 💉 حقن التبعيات — get_it

Service Locator بيسجل الخدمات مرة واحدة (مثل SupabaseClient والـ Repositories) وبيتيح الوصول لها من أي مكان. الفائدة الأكبر: استبدال أي خدمة بـ Mock بسهولة أثناء الاختبار.

---

### 🔐 المصادقة وقاعدة البيانات — supabase_flutter

SDK رسمي لـ Supabase، بيوفر Authentication وDatabase (PostgreSQL) وStorage وRealtime — كل عمليات التطبيق تمر عبره.

---

### 🧭 التنقل — go_router

تنقل تعريفي بتعرّف فيه كل المسارات بمكان واحد، مع دعم Deep Links وتمرير المعاملات (/lecture/:id) وحماية الشاشات اللي تتطلب تسجيل دخول.

---

### 🎯 توليد QR — qr_flutter

بيولّد QR Code من بيانات الحجز، يعرضه المستخدم للمنظّم للتحقق منه بسرعة بدون كتابة.

---

### 🗺️ الخرائط — flutter_map + latlong2

بديل مفتوح المصدر لـ Google Maps (مجاني بالكامل). flutter_map بيعرض الخريطة على OpenStreetMap، وlatlong2 بتدير الإحداثيات. بالمشروع: عرض موقع المحاضرة والاتجاهات للوصول.

---

### 💾 التخزين المحلي (Offline) — hive_ce

قاعدة بيانات محلية سريعة (Key-Value بدون SQL) بتخزن الكائنات مباشرة بعد توليد Adapters. بالمشروع: Cache للمحاضرات والمقالات والمفضلة عشان تشتغل بدون إنترنت.

---

### 🔔 الإشعارات — firebase_messaging + flutter_local_notifications + timezone

- **firebase_messaging:** Push Notifications من السيرفر (محتوى جديد).
- **flutter_local_notifications:** إشعارات مجدولة محليًا على الجهاز (تذكير بالمحاضرة).
- **timezone:** تضمن دقة الجدولة عبر المناطق الزمنية.

---

### 🧪 الاختبارات — bloc_test + mocktail

- **bloc_test:** بيوفر blocTest() لكتابة اختبار BLoC بشكل مختصر (Events → States متوقعة).
- **mocktail:** بيعمل Mock لأي class (مثل الـ Repositories) بدون كود إضافي.

الوضع الحالي: 🚧 تم تجربة bloc_test على سيناريو واحد للتأكد من الإعدادات، والخطة توسيع التغطية لباقي الـ Blocs.

dart
blocTest<LectureBloc, LectureState>(
  'يرجع Loaded عند نجاح جلب المحاضرات',
  build: () {
    when(() => repo.getLectures()).thenAnswer((_) async => mockLectures);
    return LectureBloc(repo);
  },
  act: (bloc) => bloc.add(FetchLectures()),
  expect: () => [Loading(), Loaded(mockLectures)],
);

---

## ⚙️ طريقة التشغيل (Getting Started)

``bash
# 1. Clone the repository
git clone [https://github.com/alkhadraaman-IT/al_zakat_of_knowledge_app.git](https://github.com/alkhadraaman-IT/al_zakat_of_knowledge_app) 

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
