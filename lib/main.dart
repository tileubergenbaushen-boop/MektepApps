// =============================================================
//  MektepApp — оқушылар мен студенттерге арналған қосымша
//  Сабақ кестесі, үй тапсырмалары және конспектілер бір жерде.
//
//  DartPad-та іске қосу:
//   1) dartpad.dev сайтын ашыңыз;
//   2) сол жақтағы бар кодты толығымен өшіріңіз;
//   3) осы файлды түгел көшіріп қойып, "Run" батырмасын басыңыз.
//  Қосымша оң жақта телефон экраны түрінде ашылады.
//
//  Код тек Flutter пакеттерін және dart:async-ты қолданады
//  (dart:io жоқ), сондықтан DartPad-та бірден жұмыс істейді.
//  Дайын деректерді өзгерту үшін «ДЕРЕКТЕР» бөлімін қараңыз.
//
//  Интерактивті мүмкіндіктер:
//   • «Қосу» / «+» батырмасы — жаңа сабақ, үй тапсырмасы немесе конспект
//     қосатын диалогтық терезе ашылады;
//   • үй тапсырмасындағы чекбокс — орындалды / орындалмады;
//   • конспектіні басқанда — толық оқу беті ашылады (A− / A+ әріп өлшемі).
// =============================================================

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MektepApp());

// ===================== ТҮСТЕР =====================

class AppColors {
  static const primary = Color(0xFF4F46E5);
  static const accent = Color(0xFF7C3AED);
  static const background = Color(0xFFF4F5FB);
  static const textDark = Color(0xFF1E1B4B);
  static const textMuted = Color(0xFF6B7280);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF10B981);
}

/// Барлық тақырыптарда (header) қолданылатын градиент.
const kAppGradient = LinearGradient(
  colors: [AppColors.primary, AppColors.accent],
);

// ===================== ДЕРЕКТЕР =====================
//  Барлық дайын деректер осы бөлімде. Өз кестеңізді, тапсырмаларыңызды
//  және конспектілеріңізді енгізу үшін тек осы бөлімді өзгертсеңіз болады.

/// Пән: атауы, белгішесі, түсі, мұғалімі және негізгі кабинеті.
class Subject {
  const Subject(this.name, this.icon, this.color, this.teacher, this.room);

  final String name;
  final IconData icon;
  final Color color;
  final String teacher;
  final String room;
}

const kMath = Subject(
  'Математика',
  Icons.calculate_rounded,
  Color(0xFF6366F1),
  'Айгүл Серікқызы',
  '204-кабинет',
);
const kPhysics = Subject(
  'Физика',
  Icons.science_rounded,
  Color(0xFFF97316),
  'Ерлан Бекұлы',
  '311-кабинет',
);
const kInformatics = Subject(
  'Информатика',
  Icons.computer_rounded,
  Color(0xFF14B8A6),
  'Динара Маратқызы',
  '105-кабинет',
);
const kHistory = Subject(
  'Тарих',
  Icons.account_balance_rounded,
  Color(0xFFE11D48),
  'Бауыржан Төлегенұлы',
  '215-кабинет',
);
const kEnglish = Subject(
  'Ағылшын тілі',
  Icons.translate_rounded,
  Color(0xFF0EA5E9),
  'Мадина Асқарқызы',
  '118-кабинет',
);
const kSubjects = [kMath, kPhysics, kInformatics, kHistory, kEnglish];

/// Қоңырау кестесі (1–7 сабақтың басталу және аяқталу уақыты).
/// 6–7 уақыттар жаңа сабақ қосу үшін бос тұр.
const kBellStart = [
  TimeOfDay(hour: 8, minute: 30),
  TimeOfDay(hour: 9, minute: 25),
  TimeOfDay(hour: 10, minute: 20),
  TimeOfDay(hour: 11, minute: 20),
  TimeOfDay(hour: 12, minute: 15),
  TimeOfDay(hour: 13, minute: 10),
  TimeOfDay(hour: 14, minute: 5),
];
const kBellEnd = [
  TimeOfDay(hour: 9, minute: 15),
  TimeOfDay(hour: 10, minute: 10),
  TimeOfDay(hour: 11, minute: 5),
  TimeOfDay(hour: 12, minute: 5),
  TimeOfDay(hour: 13, minute: 0),
  TimeOfDay(hour: 13, minute: 55),
  TimeOfDay(hour: 14, minute: 50),
];

/// Бір сабақ: реттік нөмірі (1–7), пәні, тақырыбы және кабинеті.
class Lesson {
  const Lesson(this.number, this.subject, this.topic, {this.customRoom});

  final int number;
  final Subject subject;
  final String topic;

  /// Сабақ пәннің әдеттегі кабинетінен басқа жерде өтсе (мысалы,
  /// зертханада), кабинет осы жерге жазылады.
  final String? customRoom;

  String get room => customRoom ?? subject.room;
  TimeOfDay get start => kBellStart[number - 1];
  TimeOfDay get end => kBellEnd[number - 1];
  int get startMinutes => start.hour * 60 + start.minute;
  int get endMinutes => end.hour * 60 + end.minute;
}

/// Апталық сабақ кестесі (дүйсенбі–жұма, күніне 4–5 сабақ).
/// «Қосу» диалогы арқылы жаңа сабақтар осы тізімге қосылады.
final Map<int, List<Lesson>> weekSchedule = {
  DateTime.monday: [
    Lesson(1, kMath, 'Квадрат теңдеулер'),
    Lesson(2, kEnglish, 'Present Simple'),
    Lesson(3, kPhysics, 'Ньютон заңдары'),
    Lesson(4, kHistory, 'Қазақ хандығының құрылуы'),
    Lesson(5, kInformatics, 'Python: айнымалылар'),
  ],
  DateTime.tuesday: [
    Lesson(1, kInformatics, 'Алгоритмдер және блок-схемалар'),
    Lesson(2, kMath, 'Виет теоремасы'),
    Lesson(3, kHistory, 'Қасым хан билігі'),
    Lesson(4, kEnglish, 'Лексика: «My School Day»'),
  ],
  DateTime.wednesday: [
    Lesson(1, kPhysics, 'Зертханалық жұмыс №2', customRoom: '302-зертхана'),
    Lesson(2, kMath, 'Функция графигі'),
    Lesson(3, kEnglish, 'Irregular verbs'),
    Lesson(4, kInformatics, 'Python: шартты операторлар'),
    Lesson(5, kHistory, 'Тәуке хан және «Жеті жарғы»'),
  ],
  DateTime.thursday: [
    Lesson(1, kMath, 'Бақылау жұмысы'),
    Lesson(2, kPhysics, 'Импульс'),
    Lesson(3, kHistory, 'Қазақ хандығының нығаюы'),
    Lesson(4, kEnglish, 'Past Simple'),
  ],
  DateTime.friday: [
    Lesson(1, kInformatics, 'Жоба: калькулятор'),
    Lesson(2, kEnglish, 'Speaking: Hobbies'),
    Lesson(3, kPhysics, 'Энергия және жұмыс'),
    Lesson(4, kMath, 'Қайталау сабағы'),
    Lesson(5, kHistory, 'Тақырыптық тест'),
  ],
};

/// Үй тапсырмасы.
class Homework {
  Homework({
    required this.subject,
    required this.title,
    required this.description,
    required this.deadline,
    this.done = false,
  });

  final Subject subject;
  final String title;
  final String description;
  final DateTime deadline;
  bool done;
}

/// Бастапқы үй тапсырмалары: 4 белсенді + 1 орындалған.
/// Мерзімдер бүгінгі күнге қатысты есептеледі (0 — бүгін, 1 — ертең...).
List<Homework> initialHomeworks() => [
      Homework(
        subject: kPhysics,
        title: 'Зертханалық жұмыстың есебін дайындау',
        description: '№2 зертханалық жұмыс: өлшеулер кестесі мен қорытынды',
        deadline: daysFromToday(0),
      ),
      Homework(
        subject: kMath,
        title: '№245–250 есептерді шығару',
        description: '§12 «Квадрат теңдеулер» тақырыбы',
        deadline: daysFromToday(1),
      ),
      Homework(
        subject: kEnglish,
        title: '10 бұрыс етістікті жаттау',
        description: 'Үш формасымен: go – went – gone, see – saw – seen т.б.',
        deadline: daysFromToday(2),
      ),
      Homework(
        subject: kHistory,
        title: 'Қазақ хандығы туралы баяндама',
        description: 'Керей мен Жәнібек туралы 1 беттік баяндама жазу',
        deadline: daysFromToday(3),
      ),
      Homework(
        subject: kInformatics,
        title: 'Блок-схема сызу',
        description: 'Квадрат теңдеуді шешу алгоритмінің блок-схемасы',
        deadline: daysFromToday(-1),
        done: true,
      ),
    ];

/// Конспект.
class Note {
  const Note(this.subject, this.title, this.updated, this.body);

  final Subject subject;
  final String title;
  final String updated;
  final String body;
}

/// Дайын конспектілер: математика, тарих және ағылшын тілі.
/// «Қосу» диалогы арқылы жаңа конспектілер осы тізімге қосылады.
final List<Note> allNotes = [
  Note(
    kMath,
    'Квадрат теңдеу формулалары',
    'Бүгін',
    'Жалпы түрі: ax² + bx + c = 0 (a ≠ 0)\n\n'
        'Дискриминант: D = b² − 4ac\n'
        '• D > 0 — екі түбір\n'
        '• D = 0 — бір түбір\n'
        '• D < 0 — нақты түбірі жоқ\n\n'
        'Түбірлер: x = (−b ± √D) / 2a\n\n'
        'Виет теоремасы: x₁ + x₂ = −b/a,  x₁·x₂ = c/a',
  ),
  Note(
    kHistory,
    'Қазақ хандығының құрылуы',
    'Кеше',
    'Қазақ хандығы 1465 жылы құрылды.\n\n'
        'Негізін қалағандар — Керей мен Жәнібек сұлтандар. Олар Әбілқайыр '
        'хандығынан бөлініп, Жетісудың батысына, Шу мен Талас өзендерінің '
        'бойына (Қозыбасы) көшіп келді.\n\n'
        'Негізгі дереккөз — Мұхаммед Хайдар Дулатидің «Тарих-и Рашиди» '
        'еңбегі.\n\n'
        'Қасым хан тұсында (XVI ғасырдың басы) хандық күшейіп, халқының саны '
        '1 миллионға жетті. Оның заңдары «Қасым ханның қасқа жолы» деп '
        'аталады.',
  ),
  Note(
    kEnglish,
    'Present Simple',
    '2 күн бұрын',
    'Қолданылуы: күнделікті, қайталанып тұратын әрекеттер және жалпы '
        'ақиқаттар.\n\n'
        'Құрылымы:\n'
        '• I / You / We / They + V\n'
        '• He / She / It + V-s (-es)\n\n'
        "Болымсыз түрі: don't / doesn't + V\n"
        'Сұраулы түрі: Do / Does + бастауыш + V?\n\n'
        'Белгі сөздер: always, usually, often, sometimes, never, every day.\n\n'
        'Мысалдар:\n'
        'She goes to school every day.\n'
        "They don't play football on Monday.\n"
        'Do you like English?',
  ),
  Note(
    kMath,
    'Функция графиктері',
    '3 күн бұрын',
    'y = kx + b — сызықтық функция, графигі — түзу.\n'
        'k — бұрыштық коэффициент.\n\n'
        'y = ax² + bx + c — квадраттық функция, графигі — парабола.\n'
        'a > 0 болса, парабола тармақтары жоғары, a < 0 болса, төмен '
        'бағытталады.\n\n'
        'Парабола төбесі: x₀ = −b / 2a',
  ),
  Note(
    kHistory,
    'Тәуке хан және «Жеті жарғы»',
    '5 күн бұрын',
    'Тәуке хан 1680–1715 жылдары билік құрды.\n\n'
        'Оның тұсында «Жеті жарғы» заңдар жинағы қабылданды. Онда жер дауы, '
        'құн дауы, жесір дауы, әскери міндет сияқты мәселелер реттелді.\n\n'
        'Заңдарды әзірлеуге үш жүздің атақты билері қатысты:\n'
        '• Төле би — Ұлы жүз\n'
        '• Қазыбек би — Орта жүз\n'
        '• Әйтеке би — Кіші жүз\n\n'
        'Бұл кезең халық арасында «қой үстіне бозторғай жұмыртқалаған заман» '
        'деп аталады.',
  ),
  Note(
    kEnglish,
    'Бұрыс етістіктер',
    '1 апта бұрын',
    'V1 – V2 – V3 — аудармасы\n\n'
        'be – was/were – been — болу\n'
        'go – went – gone — бару\n'
        'have – had – had — ие болу\n'
        'do – did – done — істеу\n'
        'see – saw – seen — көру\n'
        'write – wrote – written — жазу\n'
        'read – read – read — оқу\n'
        'take – took – taken — алу\n'
        'come – came – come — келу\n'
        'speak – spoke – spoken — сөйлеу\n\n'
        'Кеңес: күніне 5 етістіктен жаттап, әрқайсысымен бір сөйлем құраңыз.',
  ),
];

// ===================== КӨМЕКШІ ФУНКЦИЯЛАР =====================

const kDayNames = [
  'Дүйсенбі',
  'Сейсенбі',
  'Сәрсенбі',
  'Бейсенбі',
  'Жұма',
  'Сенбі',
  'Жексенбі',
];
const kDayShort = ['Дс', 'Сс', 'Ср', 'Бс', 'Жм', 'Сн', 'Жс'];
const kMonths = [
  'қаңтар',
  'ақпан',
  'наурыз',
  'сәуір',
  'мамыр',
  'маусым',
  'шілде',
  'тамыз',
  'қыркүйек',
  'қазан',
  'қараша',
  'желтоқсан',
];

String twoDigits(int n) => n.toString().padLeft(2, '0');

String formatTime(TimeOfDay t) => '${twoDigits(t.hour)}:${twoDigits(t.minute)}';

String formatDate(DateTime d) =>
    '${d.day} ${kMonths[d.month - 1]}, ${kDayNames[d.weekday - 1].toLowerCase()}';

String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Қайырлы таң';
  if (now.hour < 18) return 'Қайырлы күн';
  return 'Қайырлы кеш';
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime daysFromToday(int days) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + days);
}

int daysUntil(DateTime deadline) {
  final diff = dateOnly(deadline).difference(dateOnly(DateTime.now()));
  return (diff.inHours / 24).round();
}

/// Орындалмағандар алдымен (мерзімі бойынша), орындалғандар соңында.
List<Homework> sortHomeworks(List<Homework> list) {
  final pending = list.where((h) => !h.done).toList()
    ..sort((a, b) => a.deadline.compareTo(b.deadline));
  final done = list.where((h) => h.done).toList();
  return [...pending, ...done];
}

/// Келесі (немесе қазір жүріп жатқан) сабақ туралы ақпарат.
class NextLessonInfo {
  const NextLessonInfo(this.lesson, this.whenLabel, {this.isNow = false});

  final Lesson lesson;
  final String whenLabel;
  final bool isNow;
}

NextLessonInfo? findNextLesson(DateTime now) {
  final nowMinutes = now.hour * 60 + now.minute;
  for (var offset = 0; offset < 7; offset++) {
    final day = DateTime(now.year, now.month, now.day + offset);
    final lessons = weekSchedule[day.weekday] ?? const <Lesson>[];
    for (final lesson in lessons) {
      if (offset == 0) {
        if (nowMinutes >= lesson.startMinutes &&
            nowMinutes < lesson.endMinutes) {
          final left = lesson.endMinutes - nowMinutes;
          return NextLessonInfo(lesson, '$left мин қалды', isNow: true);
        }
        if (nowMinutes < lesson.startMinutes) {
          final wait = lesson.startMinutes - nowMinutes;
          final label = wait <= 60
              ? '$wait минуттан кейін'
              : 'Бүгін, ${formatTime(lesson.start)}';
          return NextLessonInfo(lesson, label);
        }
      } else {
        final dayLabel = offset == 1 ? 'Ертең' : kDayNames[day.weekday - 1];
        return NextLessonInfo(lesson, '$dayLabel, ${formatTime(lesson.start)}');
      }
    }
  }
  return null;
}

/// Ақ түсті, жұмсақ көлеңкесі бар карта безендіруі.
BoxDecoration cardDecoration({double radius = 20, Border? border}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: border,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

void showAppSnackBar(
  BuildContext context,
  String text, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(text),
        action: action,
      ),
    );
}

// ===================== ҚОСЫМША =====================

/// Веб-нұсқада тышқанмен де айналдыруға (scroll) мүмкіндік береді.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class MektepApp extends StatelessWidget {
  const MektepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MektepApp',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      ),
      // Бүкіл қосымшаны телефон қаңқасының ішіне орналастырамыз.
      builder: (context, child) =>
          PhoneFrame(child: child ?? const SizedBox.shrink()),
      home: const HomeShell(),
    );
  }
}

// ===================== ТЕЛЕФОН ҚАҢҚАСЫ =====================

/// Қосымшаны смартфон экраны сияқты етіп көрсетеді:
/// қара жақтау, «кесік» (notch), күй жолағы және төменгі сызық.
/// Нақты телефонда (тар экранда) қаңқа көрсетілмейді.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  final Widget child;

  static const double screenWidth = 390;
  static const double screenHeight = 844;
  static const double bezel = 12;
  static const double statusBarHeight = 50;
  static const double homeIndicatorHeight = 26;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width < 450) return child;

    const insets = EdgeInsets.only(
      top: statusBarHeight,
      bottom: homeIndicatorHeight,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFF3E8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: screenWidth + bezel * 2,
              height: screenHeight + bezel * 2,
              padding: const EdgeInsets.all(bezel),
              decoration: BoxDecoration(
                color: const Color(0xFF111114),
                borderRadius: BorderRadius.circular(58),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF312E81).withValues(alpha: 0.35),
                    blurRadius: 50,
                    offset: const Offset(0, 24),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(46),
                child: MediaQuery(
                  data: media.copyWith(
                    size: const Size(screenWidth, screenHeight),
                    padding: insets,
                    viewPadding: insets,
                    viewInsets: EdgeInsets.zero,
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(child: child),
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(child: PhoneStatusBar()),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 8,
                        child: IgnorePointer(
                          child: Center(
                            child: Container(
                              width: 134,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Телефонның жоғарғы күй жолағы: уақыт, байланыс, Wi-Fi, батарея.
class PhoneStatusBar extends StatefulWidget {
  const PhoneStatusBar({super.key});

  @override
  State<PhoneStatusBar> createState() => _PhoneStatusBarState();
}

class _PhoneStatusBarState extends State<PhoneStatusBar> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: PhoneFrame.statusBarHeight,
        decoration: const BoxDecoration(gradient: kAppGradient),
        child: Stack(
          children: [
            // «Кесік» (Dynamic Island)
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 120,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 36,
              right: 26,
              child: Row(
                children: [
                  Text(
                    '${twoDigits(_now.hour)}:${twoDigits(_now.minute)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.signal_cellular_alt,
                    color: Colors.white,
                    size: 17,
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.wifi_rounded, color: Colors.white, size: 17),
                  const SizedBox(width: 5),
                  // Батарея
                  Container(
                    width: 25,
                    height: 12,
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 1.5),
                  Container(
                    width: 2,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== НЕГІЗГІ ҚАҢҚА (төменгі мәзір) =====================

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  DateTime _now = DateTime.now();
  final List<Homework> _homeworks = initialHomeworks();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Уақытқа байланысты бөліктер («Келесі сабақ», «Қазір») жаңарып тұрады.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openTab(int index) => setState(() => _index = index);

  void _toggleHomework(Homework h) {
    setState(() => h.done = !h.done);
    if (h.done) {
      showAppSnackBar(
        context,
        'Тапсырма орындалды деп белгіленді',
        action: SnackBarAction(
          label: 'Қайтару',
          onPressed: () {
            if (mounted) setState(() => h.done = false);
          },
        ),
      );
    }
  }

  void _deleteHomework(Homework h) {
    final index = _homeworks.indexOf(h);
    setState(() => _homeworks.remove(h));
    showAppSnackBar(
      context,
      'Тапсырма өшірілді',
      action: SnackBarAction(
        label: 'Қайтару',
        onPressed: () {
          if (!mounted) return;
          setState(() {
            final i = index > _homeworks.length ? _homeworks.length : index;
            _homeworks.insert(i, h);
          });
        },
      ),
    );
  }

  /// «Қосу» диалогын ашады. Диалог жаңа сабақ, үй тапсырмасы немесе
  /// конспект қайтарады — соған қарай тиісті тізімге қосамыз.
  Future<void> _openAddDialog([AddType initial = AddType.homework]) async {
    final result = await showDialog<Object>(
      context: context,
      builder: (_) => AddItemDialog(initialType: initial),
    );
    if (result == null || !mounted) return;

    if (result is Homework) {
      setState(() => _homeworks.add(result));
      showAppSnackBar(
        context,
        'Жаңа үй тапсырмасы қосылды',
        action: SnackBarAction(label: 'Көру', onPressed: () => _openTab(2)),
      );
    } else if (result is NewLesson) {
      setState(() {
        final list =
            weekSchedule.putIfAbsent(result.weekday, () => <Lesson>[]);
        list.add(result.lesson);
        list.sort((a, b) => a.number.compareTo(b.number));
      });
      showAppSnackBar(
        context,
        'Сабақ қосылды: ${kDayNames[result.weekday - 1]}, '
        '${result.lesson.number}-сабақ',
        action: SnackBarAction(label: 'Көру', onPressed: () => _openTab(1)),
      );
    } else if (result is Note) {
      setState(() => allNotes.insert(0, result));
      showAppSnackBar(
        context,
        'Жаңа конспект қосылды',
        action: SnackBarAction(label: 'Көру', onPressed: () => _openTab(3)),
      );
    }
  }

  /// Әр бөлімдегі «+» батырмасы: қай бөлімде тұрсақ, сол түр таңдалады.
  Widget? _buildFab() {
    if (_index == 0) return null;
    final type = _index == 1
        ? AddType.lesson
        : _index == 2
            ? AddType.homework
            : AddType.note;
    final label = _index == 1
        ? 'Сабақ қосу'
        : _index == 2
            ? 'Тапсырма қосу'
            : 'Конспект қосу';
    return FloatingActionButton.extended(
      onPressed: () => _openAddDialog(type),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            now: _now,
            homeworks: _homeworks,
            onToggle: _toggleHomework,
            onDelete: _deleteHomework,
            onAdd: () => _openAddDialog(AddType.homework),
            onOpenTab: _openTab,
          ),
          ScheduleScreen(now: _now),
          HomeworkScreen(
            homeworks: _homeworks,
            onToggle: _toggleHomework,
            onDelete: _deleteHomework,
          ),
          NotesScreen(notes: allNotes),
        ],
      ),
      floatingActionButton: _buildFab(),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _index,
        onDestinationSelected: _openTab,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Басты',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon:
                Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            label: 'Кесте',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon:
                Icon(Icons.assignment_rounded, color: AppColors.primary),
            label: 'Тапсырмалар',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon:
                Icon(Icons.menu_book_rounded, color: AppColors.primary),
            label: 'Конспектілер',
          ),
        ],
      ),
    );
  }
}

// ===================== 1. БАСТЫ БЕТ =====================
//  Бүгінгі сабақтардың қысқаша тізімі және жақын үй тапсырмалары.

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.now,
    required this.homeworks,
    required this.onToggle,
    required this.onDelete,
    required this.onAdd,
    required this.onOpenTab,
  });

  final DateTime now;
  final List<Homework> homeworks;
  final ValueChanged<Homework> onToggle;
  final ValueChanged<Homework> onDelete;
  final VoidCallback onAdd;
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final isWeekend = now.weekday > DateTime.friday;
    final shownDay = isWeekend ? DateTime.monday : now.weekday;
    final lessons = weekSchedule[shownDay] ?? const <Lesson>[];
    final nowMinutes = now.hour * 60 + now.minute;

    final total = homeworks.length;
    final doneCount = homeworks.where((h) => h.done).length;
    final pending = total - doneCount;
    final percent = total == 0 ? 0 : (doneCount * 100 / total).round();

    // Жақын арада тапсыратын (әлі орындалмаған) тапсырмалар — мерзімі бойынша.
    final upcoming =
        sortHomeworks(homeworks).where((h) => !h.done).take(3).toList();

    final lessonsSubtitle = isWeekend
        ? 'Бүгін демалыс, келесі оқу күні — дүйсенбі'
        : lessons.isEmpty
            ? 'Бүгін сабақ жоқ'
            : '${lessons.length} сабақ · '
                '${formatTime(lessons.first.start)}–${formatTime(lessons.last.end)}';

    return SingleChildScrollView(
      child: Column(
        children: [
          HomeHeader(now: now, next: findNextLesson(now)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Жылдам әрекет батырмалары ----
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                  decoration: cardDecoration(),
                  child: Row(
                    children: [
                      Expanded(
                        child: QuickAction(
                          icon: Icons.calendar_month_rounded,
                          label: 'Кесте',
                          color: AppColors.primary,
                          onTap: () => onOpenTab(1),
                        ),
                      ),
                      Expanded(
                        child: QuickAction(
                          icon: Icons.add_task_rounded,
                          label: 'Қосу',
                          color: AppColors.success,
                          onTap: onAdd,
                        ),
                      ),
                      Expanded(
                        child: QuickAction(
                          icon: Icons.assignment_rounded,
                          label: 'Тапсырма',
                          color: AppColors.warning,
                          onTap: () => onOpenTab(2),
                        ),
                      ),
                      Expanded(
                        child: QuickAction(
                          icon: Icons.menu_book_rounded,
                          label: 'Конспект',
                          color: kInformatics.color,
                          onTap: () => onOpenTab(3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ---- Қысқаша статистика ----
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: Icons.event_note_rounded,
                        value: '${lessons.length}',
                        label: 'Сабақ',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        icon: Icons.pending_actions_rounded,
                        value: '$pending',
                        label: 'Тапсырма',
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        icon: Icons.task_alt_rounded,
                        value: '$percent%',
                        label: 'Орындалды',
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ---- Бүгінгі сабақтар (қысқаша тізім) ----
                SectionHeader(
                  title: isWeekend ? 'Дүйсенбідегі сабақтар' : 'Бүгінгі сабақтар',
                  subtitle: lessonsSubtitle,
                  action: TextButton(
                    onPressed: () => onOpenTab(1),
                    child: const Text('Толық кесте'),
                  ),
                ),
                const SizedBox(height: 14),
                if (lessons.isEmpty)
                  const EmptyCard(
                    icon: Icons.beach_access_rounded,
                    text: 'Бүгін сабақ жоқ — демалыңыз!',
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: cardDecoration(),
                    child: Column(
                      children: [
                        for (var i = 0; i < lessons.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          LessonRow(
                            lesson: lessons[i],
                            isNow: !isWeekend &&
                                nowMinutes >= lessons[i].startMinutes &&
                                nowMinutes < lessons[i].endMinutes,
                            isPast: !isWeekend &&
                                nowMinutes >= lessons[i].endMinutes,
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 28),

                // ---- Жақын арада тапсыратын үй тапсырмалары ----
                SectionHeader(
                  title: 'Жақын тапсырмалар',
                  subtitle: pending == 0
                      ? 'Барлығы орындалды!'
                      : '$pending тапсырма күтіп тұр',
                  action: FilledButton.tonalIcon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('Қосу'),
                  ),
                ),
                const SizedBox(height: 14),
                if (upcoming.isEmpty)
                  const EmptyCard(
                    icon: Icons.celebration_rounded,
                    text: 'Барлық тапсырма орындалды!\n'
                        'Жаңасын қосу үшін «Қосу» батырмасын басыңыз.',
                  )
                else
                  ...upcoming.map(
                    (h) => HomeworkCard(
                      key: ObjectKey(h),
                      homework: h,
                      onToggle: () => onToggle(h),
                      onDelete: () => onDelete(h),
                    ),
                  ),
                Center(
                  child: TextButton.icon(
                    onPressed: () => onOpenTab(2),
                    icon: const Icon(Icons.list_alt_rounded),
                    label: Text('Барлық тапсырмалар ($total)'),
                  ),
                ),
                const SizedBox(height: 16),

                // ---- Соңғы конспектілер ----
                SectionHeader(
                  title: 'Соңғы конспектілер',
                  subtitle: 'Жақында ашылған жазбалар',
                  action: TextButton(
                    onPressed: () => onOpenTab(3),
                    child: const Text('Барлығы'),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 132,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: allNotes.length < 3 ? allNotes.length : 3,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, i) => NoteCard(
                      note: allNotes[i],
                      width: 172,
                      onTap: () => openNote(context, allNotes[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Бас экранның градиентті жоғарғы бөлігі.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.now, required this.next});

  final DateTime now;
  final NextLessonInfo? next;

  @override
  Widget build(BuildContext context) {
    final info = next;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: kAppGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MektepApp',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          formatDate(now),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        showAppSnackBar(context, 'Жаңа хабарламалар жоқ'),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                '${greetingFor(now)}, оқушы!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Күніңіз сәтті өтсін!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 15,
                ),
              ),
              if (info != null) ...[
                const SizedBox(height: 18),
                NextLessonCard(info: info),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== 2. САБАҚ КЕСТЕСІ =====================
//  Дүйсенбі–жұма: пән аты, уақыты, кабинеті. Екі көрініс бар:
//  «Бүкіл апта» (барлық күн бір бетте) және «Күн бойынша».

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, required this.now});

  final DateTime now;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _weekView = true;
  late int _day;

  @override
  void initState() {
    super.initState();
    final weekday = widget.now.weekday;
    // Демалыс күндері «Күн бойынша» көрінісі дүйсенбіден басталады.
    _day = weekday <= DateTime.friday ? weekday : DateTime.monday;
  }

  int _weeklyCount(Subject s) {
    var count = 0;
    for (final lessons in weekSchedule.values) {
      count += lessons.where((l) => l.subject == s).length;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final now = widget.now;
    final lessons = weekSchedule[_day] ?? const <Lesson>[];
    final isToday = _day == now.weekday;
    final nowMinutes = now.hour * 60 + now.minute;
    final weekTotal =
        weekSchedule.values.fold<int>(0, (sum, l) => sum + l.length);

    return SingleChildScrollView(
      child: Column(
        children: [
          GradientHeader(
            title: 'Сабақ кестесі',
            subtitle: 'Дүйсенбі–жұма · аптасына $weekTotal сабақ',
            icon: Icons.calendar_month_rounded,
            // Пәндер көп болғандықтан, карталар көлденең айналады.
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < kSubjects.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    SubjectCountTile(
                      subject: kSubjects[i],
                      count: _weeklyCount(kSubjects[i]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ViewToggle(
                  options: const ['Бүкіл апта', 'Күн бойынша'],
                  selected: _weekView ? 0 : 1,
                  onChanged: (i) => setState(() => _weekView = i == 0),
                ),
                const SizedBox(height: 18),
                if (_weekView) ...[
                  for (var d = DateTime.monday; d <= DateTime.friday; d++)
                    DayScheduleCard(weekday: d, now: now),
                ] else ...[
                  DaySelector(
                    selected: _day,
                    today: now.weekday,
                    onChanged: (d) => setState(() => _day = d),
                  ),
                  const SizedBox(height: 22),
                  SectionHeader(
                    title: kDayNames[_day - 1],
                    subtitle: lessons.isEmpty
                        ? 'Сабақ жоқ'
                        : '${lessons.length} сабақ · '
                            '${formatTime(lessons.first.start)}–${formatTime(lessons.last.end)}',
                  ),
                  const SizedBox(height: 14),
                  if (lessons.isEmpty)
                    const EmptyCard(
                      icon: Icons.beach_access_rounded,
                      text: 'Бұл күні сабақ жоқ — демалыңыз!',
                    )
                  else
                    ...lessons.map(
                      (l) => LessonCard(
                        lesson: l,
                        isNow: isToday &&
                            nowMinutes >= l.startMinutes &&
                            nowMinutes < l.endMinutes,
                        isPast: isToday && nowMinutes >= l.endMinutes,
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                const BellScheduleCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== 3. ҮЙ ТАПСЫРМАЛАРЫ =====================
//  Әр тапсырмада чекбокс бар: құсбелгі қойсаңыз — «Орындалды»
//  бөліміне ауысады, алып тастасаңыз — қайта «Орындалуы керек» болады.

class HomeworkScreen extends StatelessWidget {
  const HomeworkScreen({
    super.key,
    required this.homeworks,
    required this.onToggle,
    required this.onDelete,
  });

  final List<Homework> homeworks;
  final ValueChanged<Homework> onToggle;
  final ValueChanged<Homework> onDelete;

  Widget _card(Homework h) => HomeworkCard(
        key: ObjectKey(h),
        homework: h,
        onToggle: () => onToggle(h),
        onDelete: () => onDelete(h),
      );

  @override
  Widget build(BuildContext context) {
    final pendingList =
        sortHomeworks(homeworks).where((h) => !h.done).toList();
    final doneList = homeworks.where((h) => h.done).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          GradientHeader(
            title: 'Үй тапсырмалары',
            subtitle: pendingList.isEmpty
                ? 'Барлығы орындалды!'
                : '${pendingList.length} тапсырма орындалуы керек',
            icon: Icons.assignment_rounded,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProgressCard(done: doneList.length, total: homeworks.length),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Орындалса — құсбелгі қойыңыз. '
                        'Өшіру үшін солға сырғытыңыз.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'Орындалуы керек',
                  subtitle: '${pendingList.length} тапсырма',
                ),
                const SizedBox(height: 12),
                if (pendingList.isEmpty)
                  const EmptyCard(
                    icon: Icons.celebration_rounded,
                    text: 'Барлық тапсырма орындалды!',
                  )
                else
                  ...pendingList.map(_card),
                if (doneList.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: 'Орындалды',
                    subtitle: '${doneList.length} тапсырма',
                  ),
                  const SizedBox(height: 12),
                  ...doneList.map(_card),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== 4. КОНСПЕКТІЛЕР =====================
//  Қысқаша дайын конспектілер тізімі. Басқанда толық мәтіні ашылады.

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key, required this.notes});

  final List<Note> notes;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  Subject? _subject; // null — барлық пәндер

  Widget _subjectChip(Subject? s) {
    final selected = _subject == s;
    final color = s?.color ?? AppColors.primary;
    return ChoiceChip(
      showCheckmark: false,
      selected: selected,
      onSelected: (_) => setState(() => _subject = s),
      selectedColor: color,
      backgroundColor: Colors.white,
      side: BorderSide.none,
      avatar: s == null
          ? null
          : Icon(s.icon, size: 18, color: selected ? Colors.white : s.color),
      label: Text(
        s?.name ?? 'Барлығы',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = _subject == null
        ? widget.notes
        : widget.notes.where((n) => n.subject == _subject).toList();
    // Сүзгіде тек конспектісі бар пәндер көрсетіледі.
    final noteSubjects = kSubjects
        .where((s) => widget.notes.any((n) => n.subject == s))
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          GradientHeader(
            title: 'Конспектілер',
            subtitle: '${widget.notes.length} жазба · ${noteSubjects.length} пән',
            icon: Icons.menu_book_rounded,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _subjectChip(null),
                    for (final s in noteSubjects) _subjectChip(s),
                  ],
                ),
                const SizedBox(height: 16),
                if (notes.isEmpty)
                  const EmptyCard(
                    icon: Icons.description_outlined,
                    text: 'Бұл пән бойынша конспект жоқ',
                  )
                else
                  ...notes.map(
                    (n) => NoteListTile(
                      note: n,
                      onTap: () => openNote(context, n),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== ОРТАҚ ВИДЖЕТТЕР =====================

/// Бөлімдердің градиентті жоғарғы бөлігі.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.child,
  });

  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final extra = child;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: kAppGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                ],
              ),
              if (extra != null) ...[
                const SizedBox(height: 18),
                extra,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// «Келесі сабақ» картасы (бас экранның жоғарғы бөлігінде).
class NextLessonCard extends StatelessWidget {
  const NextLessonCard({super.key, required this.info});

  final NextLessonInfo info;

  @override
  Widget build(BuildContext context) {
    final lesson = info.lesson;
    final s = lesson.subject;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(s.icon, color: s.color, size: 27),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.isNow ? 'ҚАЗІРГІ САБАҚ' : 'КЕЛЕСІ САБАҚ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatTime(lesson.start)}–${formatTime(lesson.end)} · ${lesson.room}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              info.whenLabel,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Дөңгелек белгішесі бар жылдам әрекет батырмасы.
class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: SizedBox(
              width: 54,
              height: 54,
              child: Icon(icon, color: color, size: 26),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Кесте бетіндегі пән бойынша апталық сабақ саны.
class SubjectCountTile extends StatelessWidget {
  const SubjectCountTile({
    super.key,
    required this.subject,
    required this.count,
  });

  final Subject subject;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(subject.icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(
            '$count сабақ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subject.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final trailing = action;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}

/// Апта күндерін таңдау батырмалары (Дс–Жм).
class DaySelector extends StatelessWidget {
  const DaySelector({
    super.key,
    required this.selected,
    required this.today,
    required this.onChanged,
  });

  final int selected;
  final int today;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final day = i + 1;
        final isSelected = day == selected;
        final isToday = day == today;
        final count = weekSchedule[day]?.length ?? 0;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onChanged(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isToday && !isSelected
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: isSelected ? 12 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      kDayShort[i],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isToday ? 'бүгін' : '$count сабақ',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.85)
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Кестедегі бір сабақтың картасы.
class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    this.isNow = false,
    this.isPast = false,
  });

  final Lesson lesson;
  final bool isNow;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final s = lesson.subject;
    return Opacity(
      opacity: isPast ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Уақыт бағаны
            SizedBox(
              width: 48,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatTime(lesson.start),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      formatTime(lesson.end),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Сабақ картасы
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: cardDecoration(
                  radius: 18,
                  border: Border.all(
                    color: isNow ? s.color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: s.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(s.icon, color: s.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  s.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${lesson.number}-сабақ',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const Spacer(),
                              if (isNow)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: s.color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Қазір',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lesson.topic,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              InfoLabel(
                                icon: Icons.meeting_room_outlined,
                                text: lesson.room,
                              ),
                              InfoLabel(
                                icon: Icons.person_outline_rounded,
                                text: s.teacher,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoLabel extends StatelessWidget {
  const InfoLabel({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

/// Қоңырау кестесі картасы.
class BellScheduleCard extends StatelessWidget {
  const BellScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Қоңырау кестесі',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < kBellStart.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${i + 1}-сабақ',
                    style: const TextStyle(color: AppColors.textDark),
                  ),
                  const Spacer(),
                  Text(
                    '${formatTime(kBellStart[i])} – ${formatTime(kBellEnd[i])}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Тапсырмалардың орындалу прогресі.
class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$done / $total тапсырма орындалды',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, v, child) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                color: AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Үй тапсырмасының мерзімі туралы жазу және оның түсі.
class DeadlineInfo {
  const DeadlineInfo(this.label, this.color);

  final String label;
  final Color color;
}

/// Үй тапсырмасының картасы: чекбокс — орындалды/орындалмады,
/// солға сырғыту — өшіру.
class HomeworkCard extends StatelessWidget {
  const HomeworkCard({
    super.key,
    required this.homework,
    required this.onToggle,
    required this.onDelete,
  });

  final Homework homework;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  DeadlineInfo _deadlineInfo() {
    if (homework.done) {
      return const DeadlineInfo('Орындалды', AppColors.success);
    }
    final d = homework.deadline;
    // Мысалы: «Ертең · 5 қазан»
    final date = '${d.day} ${kMonths[d.month - 1]}';
    final days = daysUntil(d);
    if (days < 0) return DeadlineInfo('Мерзімі өтті · $date', AppColors.danger);
    if (days == 0) return DeadlineInfo('Бүгін · $date', AppColors.danger);
    if (days == 1) return DeadlineInfo('Ертең · $date', AppColors.warning);
    return DeadlineInfo('$days күн қалды · $date', AppColors.textMuted);
  }

  @override
  Widget build(BuildContext context) {
    final h = homework;
    final s = h.subject;
    final deadline = _deadlineInfo();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ObjectKey(h),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Өшіру',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        child: Container(
          decoration: cardDecoration(radius: 18),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 10, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Чекбокс: орындалды / орындалмады
                    Checkbox(
                      value: h.done,
                      onChanged: (_) => onToggle(),
                      activeColor: AppColors.success,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: h.done
                                    ? AppColors.textMuted
                                    : AppColors.textDark,
                                decoration: h.done
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            if (h.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                h.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                TagChip(
                                  icon: s.icon,
                                  text: s.name,
                                  color: s.color,
                                ),
                                TagChip(
                                  icon: Icons.schedule_rounded,
                                  text: deadline.label,
                                  color: deadline.color,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// «Қазір» белгісі (қазір жүріп жатқан сабаққа).
class NowBadge extends StatelessWidget {
  const NowBadge({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Қазір',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Сабақтың ықшам жолы: пән аты, кабинеті және уақыты.
class LessonRow extends StatelessWidget {
  const LessonRow({
    super.key,
    required this.lesson,
    this.isNow = false,
    this.isPast = false,
  });

  final Lesson lesson;
  final bool isNow;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final s = lesson.subject;
    return Opacity(
      opacity: isPast ? 0.5 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: s.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(s.icon, color: s.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          s.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      if (isNow) ...[
                        const SizedBox(width: 6),
                        NowBadge(color: s.color),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.meeting_room_outlined,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${lesson.room} · ${lesson.number}-сабақ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatTime(lesson.start),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  formatTime(lesson.end),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Бір күннің толық кестесі (апталық көрініс үшін).
class DayScheduleCard extends StatelessWidget {
  const DayScheduleCard({super.key, required this.weekday, required this.now});

  final int weekday;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final lessons = weekSchedule[weekday] ?? const <Lesson>[];
    final isToday = weekday == now.weekday;
    final nowMinutes = now.hour * 60 + now.minute;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        decoration: cardDecoration(
          border: isToday
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 1.5,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    kDayShort[weekday - 1],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isToday ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            kDayNames[weekday - 1],
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Бүгін',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        lessons.isEmpty
                            ? 'Сабақ жоқ'
                            : '${lessons.length} сабақ · '
                                '${formatTime(lessons.first.start)}–${formatTime(lessons.last.end)}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < lessons.length; i++) ...[
              const Divider(height: 1),
              LessonRow(
                lesson: lessons[i],
                isNow: isToday &&
                    nowMinutes >= lessons[i].startMinutes &&
                    nowMinutes < lessons[i].endMinutes,
                isPast: isToday && nowMinutes >= lessons[i].endMinutes,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Екі көріністің бірін таңдайтын ауыстырғыш (мысалы, «Бүкіл апта» / «Күн бойынша»).
class ViewToggle extends StatelessWidget {
  const ViewToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: cardDecoration(radius: 16),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    options[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: i == selected
                          ? Colors.white
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Конспектілер тізіміндегі бір жол: тақырыбы, пәні және қысқа үзінді.
class NoteListTile extends StatelessWidget {
  const NoteListTile({super.key, required this.note, required this.onTap});

  final Note note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = note.subject;
    final preview = note.body.replaceAll(RegExp(r'\s+'), ' ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: cardDecoration(radius: 18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: s.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(s.icon, color: s.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${s.name} · ${note.updated}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: s.color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Конспект картасы (басқанда толық мәтіні ашылады).
class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note, this.width, this.onTap});

  final Note note;
  final double? width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = note.subject;
    return Material(
      color: s.color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(s.icon, color: s.color, size: 20),
              ),
              const Spacer(),
              Text(
                note.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${s.name} · ${note.updated}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyCard extends StatelessWidget {
  const EmptyCard({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: cardDecoration(),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ===================== КОНСПЕКТІНІ ТОЛЫҚ ОҚУ =====================

/// Конспектіні толық экранда оқу бетіне өтеді.
void openNote(BuildContext context, Note note) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => NoteReaderScreen(note: note)),
  );
}

/// Конспектінің толық мәтіні: артқа қайту, әріп өлшемін өзгерту (A− / A+),
/// мәтінді белгілеп көшіруге болады.
class NoteReaderScreen extends StatefulWidget {
  const NoteReaderScreen({super.key, required this.note});

  final Note note;

  @override
  State<NoteReaderScreen> createState() => _NoteReaderScreenState();
}

class _NoteReaderScreenState extends State<NoteReaderScreen> {
  double _fontSize = 16;

  void _changeFont(double delta) {
    final next = _fontSize + delta;
    if (next < 13 || next > 26) return;
    setState(() => _fontSize = next);
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final s = note.subject;
    final words =
        note.body.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final minutes = (words / 120).ceil();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: kAppGradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 12, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            tooltip: 'Артқа',
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _changeFont(-1),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'A−',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _changeFont(1),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'A+',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(s.icon, color: Colors.white, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    s.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              note.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${note.updated} · шамамен $minutes мин оқу',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration(),
                    child: SelectableText(
                      note.body,
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: 1.6,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text(
                      'Оқыдым',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== «ҚОСУ» ДИАЛОГЫ =====================

/// Диалогта не қосылатыны: сабақ, үй тапсырмасы немесе конспект.
enum AddType { lesson, homework, note }

/// Диалогтан қайтатын жаңа сабақ (қай күнге қосылатыны да бар).
class NewLesson {
  const NewLesson(this.weekday, this.lesson);

  final int weekday;
  final Lesson lesson;
}

/// Берілген күндегі бос сабақ уақыттары (қоңырау кестесі бойынша).
List<int> freeSlots(int weekday) {
  final taken = (weekSchedule[weekday] ?? const <Lesson>[])
      .map((l) => l.number)
      .toSet();
  return [
    for (var n = 1; n <= kBellStart.length; n++)
      if (!taken.contains(n)) n,
  ];
}

/// Жаңа сабақ, үй тапсырмасы немесе конспект қосатын диалогтық терезе.
class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key, this.initialType = AddType.homework});

  final AddType initialType;

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  late AddType _type;
  Subject _subject = kMath;
  String? _error;

  // Үй тапсырмасы
  final _hwTitle = TextEditingController();
  final _hwDescription = TextEditingController();
  int _hwDays = 1;

  // Сабақ
  final _lessonTopic = TextEditingController();
  final _lessonRoom = TextEditingController();
  late int _lessonDay;
  int? _lessonSlot;

  // Конспект
  final _noteTitle = TextEditingController();
  final _noteBody = TextEditingController();

  static const _deadlineOptions = {
    0: 'Бүгін',
    1: 'Ертең',
    2: '2 күннен соң',
    7: 'Бір аптадан соң',
  };

  static const _titles = {
    AddType.lesson: 'Жаңа сабақ',
    AddType.homework: 'Жаңа үй тапсырмасы',
    AddType.note: 'Жаңа конспект',
  };

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    final weekday = DateTime.now().weekday;
    _lessonDay = weekday <= DateTime.friday ? weekday : DateTime.monday;
    _lessonSlot = _firstFree(_lessonDay);
  }

  @override
  void dispose() {
    _hwTitle.dispose();
    _hwDescription.dispose();
    _lessonTopic.dispose();
    _lessonRoom.dispose();
    _noteTitle.dispose();
    _noteBody.dispose();
    super.dispose();
  }

  int? _firstFree(int weekday) {
    final free = freeSlots(weekday);
    return free.isEmpty ? null : free.first;
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  void _showError(String text) => setState(() => _error = text);

  /// «Қосу» батырмасы: деректерді тексеріп, жаңа элементті қайтарады.
  void _submit() {
    if (_type == AddType.homework) {
      final title = _hwTitle.text.trim();
      if (title.isEmpty) return _showError('Тапсырманың атауын жазыңыз');
      Navigator.of(context).pop(
        Homework(
          subject: _subject,
          title: title,
          description: _hwDescription.text.trim(),
          deadline: daysFromToday(_hwDays),
        ),
      );
    } else if (_type == AddType.lesson) {
      final slot = _lessonSlot;
      if (slot == null) {
        return _showError('Бұл күні бос уақыт жоқ — басқа күнді таңдаңыз');
      }
      final topic = _lessonTopic.text.trim();
      if (topic.isEmpty) return _showError('Сабақтың тақырыбын жазыңыз');
      final room = _lessonRoom.text.trim();
      Navigator.of(context).pop(
        NewLesson(
          _lessonDay,
          Lesson(
            slot,
            _subject,
            topic,
            customRoom: room.isEmpty ? null : room,
          ),
        ),
      );
    } else {
      final title = _noteTitle.text.trim();
      final body = _noteBody.text.trim();
      if (title.isEmpty) return _showError('Конспектінің тақырыбын жазыңыз');
      if (body.isEmpty) return _showError('Конспект мәтінін жазыңыз');
      Navigator.of(context).pop(Note(_subject, title, 'Жаңа ғана', body));
    }
  }

  // ---------- Форманың ортақ бөліктері ----------

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  InputDecoration _input(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _choice(String text, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      showCheckmark: false,
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      side: BorderSide.none,
      label: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textDark,
        ),
      ),
    );
  }

  Widget _subjectPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in kSubjects)
          ChoiceChip(
            showCheckmark: false,
            selected: s == _subject,
            onSelected: (_) => setState(() => _subject = s),
            selectedColor: s.color,
            backgroundColor: s.color.withValues(alpha: 0.08),
            side: BorderSide.none,
            avatar: Icon(
              s.icon,
              size: 18,
              color: s == _subject ? Colors.white : s.color,
            ),
            label: Text(
              s.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: s == _subject ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
      ],
    );
  }

  // ---------- Әр түрдің өрістері ----------

  List<Widget> _lessonFields() {
    final free = freeSlots(_lessonDay);
    return [
      _label('Күні'),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var d = DateTime.monday; d <= DateTime.friday; d++)
            _choice(kDayShort[d - 1], d == _lessonDay, () {
              setState(() {
                _lessonDay = d;
                _lessonSlot = _firstFree(d);
                _error = null;
              });
            }),
        ],
      ),
      const SizedBox(height: 12),
      _label('Сабақ уақыты (бос орындар)'),
      if (free.isEmpty)
        const Text(
          'Бұл күні бос уақыт жоқ — басқа күнді таңдаңыз.',
          style: TextStyle(color: AppColors.textMuted),
        )
      else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final n in free)
              _choice(
                '$n-сабақ · ${formatTime(kBellStart[n - 1])}',
                n == _lessonSlot,
                () => setState(() => _lessonSlot = n),
              ),
          ],
        ),
      const SizedBox(height: 12),
      _label('Пән'),
      _subjectPicker(),
      const SizedBox(height: 16),
      TextField(
        controller: _lessonTopic,
        onChanged: (_) => _clearError(),
        decoration: _input('Сабақ тақырыбы', 'Мысалы: Тригонометрия'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _lessonRoom,
        decoration: _input(
          'Кабинет (міндетті емес)',
          'Бос қалса: ${_subject.room}',
        ),
      ),
    ];
  }

  List<Widget> _homeworkFields() {
    return [
      _label('Пән'),
      _subjectPicker(),
      const SizedBox(height: 16),
      TextField(
        controller: _hwTitle,
        onChanged: (_) => _clearError(),
        decoration: _input('Тапсырма', 'Мысалы: №120–125 есептер'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _hwDescription,
        maxLines: 2,
        decoration: _input(
          'Қосымша мәлімет (міндетті емес)',
          'Мысалы: §5 оқу',
        ),
      ),
      const SizedBox(height: 12),
      _label('Мерзімі'),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final e in _deadlineOptions.entries)
            _choice(
              e.value,
              e.key == _hwDays,
              () => setState(() => _hwDays = e.key),
            ),
        ],
      ),
    ];
  }

  List<Widget> _noteFields() {
    return [
      _label('Пән'),
      _subjectPicker(),
      const SizedBox(height: 16),
      TextField(
        controller: _noteTitle,
        onChanged: (_) => _clearError(),
        decoration: _input('Конспект тақырыбы', 'Мысалы: Пифагор теоремасы'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _noteBody,
        minLines: 4,
        maxLines: 8,
        keyboardType: TextInputType.multiline,
        onChanged: (_) => _clearError(),
        decoration: _input(
          'Мәтіні',
          'Негізгі анықтамалар, формулалар, мысалдар...',
        ).copyWith(alignLabelWithHint: true),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Тақырып және жабу батырмасы
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _titles[_type] ?? 'Жаңа жазба',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Жабу',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            // Не қосамыз: сабақ / тапсырма / конспект
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
              child: ViewToggle(
                options: const ['Сабақ', 'Тапсырма', 'Конспект'],
                selected: _type.index,
                onChanged: (i) => setState(() {
                  _type = AddType.values[i];
                  _error = null;
                }),
              ),
            ),
            // Форма
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_type == AddType.lesson) ..._lessonFields(),
                    if (_type == AddType.homework) ..._homeworkFields(),
                    if (_type == AddType.note) ..._noteFields(),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.danger,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              error,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Батырмалар
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Бас тарту'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text(
                        'Қосу',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
