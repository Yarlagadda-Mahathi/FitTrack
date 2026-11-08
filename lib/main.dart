
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const FitTrackApp());

// ---------- Theme colours ----------
const ink = Color(0xFF14213D);
const primary = Color(0xFF3A52E0);
const deep = Color(0xFF1B2A6B);
const teal = Color(0xFF0FA89B);
const orange = Color(0xFFF59E0B);
const red = Color(0xFFEF5B5B);
const background = Color(0xFFEAF3FC);

// ---------- Photos ----------
String _img(String id) =>
    'https://images.unsplash.com/photo-$id?auto=format&fit=crop&w=900&q=70';

final imgHero = _img('1571019613454-1cb2f99b2d8b');
final imgWeights = _img('1534438327276-14e5300c3a48');
final imgWorkout = _img('1517836357463-d25dfeac3438');
final imgRun = _img('1476480862126-209bfaa8edc8');
final imgYoga = _img('1544367567-0f2fcb009e0b');
final imgBike = _img('1541625602330-2277a4c46182');

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c),
    );

    return MaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: background,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: border(const Color(0xFFD5DAE8)),
          enabledBorder: border(const Color(0xFFD5DAE8)),
          focusedBorder: border(primary),
          errorBorder: border(red),
          focusedErrorBorder: border(red),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const FitnessHome(),
    );
  }
}

// ---------- Models ----------
class Workout {
  Workout(this.name, this.minutes, this.calories, this.daysAgo);

  final String name;
  final int minutes;
  final int calories;
  final int daysAgo;

  String get when => daysAgo == 0
      ? 'Today'
      : (daysAgo == 1 ? 'Yesterday' : '$daysAgo days ago');
}

class PlanExercise {
  PlanExercise(this.name, this.sets, this.reps, {this.unit = 'reps'});

  final String name;
  final int sets;
  final int reps;
  final String unit;
  bool done = false;
}

class WorkoutPlan {
  WorkoutPlan(
      this.name,
      this.focus,
      this.minutes,
      this.image,
      this.colors,
      this.exercises,
      );

  final String name;
  final String focus;
  final int minutes;
  final String image;
  final List<Color> colors;
  final List<PlanExercise> exercises;

  int get doneCount => exercises.where((e) => e.done).length;

  double get progress =>
      exercises.isEmpty ? 0 : doneCount / exercises.length;
}

class NavItem {
  const NavItem(this.icon, this.selected, this.label);

  final IconData icon;
  final IconData selected;
  final String label;
}

const caloriesPerMinute = {
  'Running': 11,
  'Cycling': 8,
  'Swimming': 9,
  'HIIT': 12,
  'Walking': 4,
  'Yoga': 3,
  'Strength': 6,
  'Arms workout': 6,
  'Leg day': 7,
  'Chest & back': 6,
  'Core': 5,
  'Full body': 8,
};

String fmt(num n) => n
    .round()
    .toString()
    .replaceAllMapped(
  RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]},',
);

// ---------- Home ----------
class FitnessHome extends StatefulWidget {
  const FitnessHome({super.key});

  @override
  State<FitnessHome> createState() => _FitnessHomeState();
}

class _FitnessHomeState extends State<FitnessHome> {
  int tab = 0;
  bool weekly = true;

  // ---------- Initial values: Fresh start ----------
  int steps = 0;
  int stepGoal = 10000;
  int calorieGoal = 600;
  int minuteGoal = 45;
  double? bmi;

  // Empty workout history at startup
  final List<Workout> workouts = [];

  // ---------- Workout plans ----------
  late final Map<String, WorkoutPlan> plans = {
    'Arms workout': WorkoutPlan(
      'Arms workout',
      'Biceps, triceps and shoulders',
      30,
      imgWeights,
      [primary, deep],
      [
        PlanExercise('Bicep curls', 3, 12),
        PlanExercise('Hammer curls', 3, 10),
        PlanExercise('Tricep dips', 3, 12),
        PlanExercise('Overhead tricep extension', 3, 10),
        PlanExercise('Shoulder press', 3, 10),
        PlanExercise('Push-ups', 3, 15),
      ],
    ),
    'Leg day': WorkoutPlan(
      'Leg day',
      'Quads, hamstrings and glutes',
      40,
      imgWorkout,
      [teal, const Color(0xFF0B5E63)],
      [
        PlanExercise('Squats', 4, 12),
        PlanExercise('Lunges', 3, 10),
        PlanExercise('Romanian deadlift', 3, 10),
        PlanExercise('Glute bridges', 3, 15),
        PlanExercise('Calf raises', 4, 15),
      ],
    ),
    'Core': WorkoutPlan(
      'Core',
      'Abs and lower back',
      20,
      imgHero,
      [orange, const Color(0xFF9A5B00)],
      [
        PlanExercise('Plank', 3, 45, unit: 'sec'),
        PlanExercise('Bicycle crunches', 3, 20),
        PlanExercise('Leg raises', 3, 12),
        PlanExercise('Russian twists', 3, 20),
      ],
    ),
    'Cardio run': WorkoutPlan(
      'Cardio run',
      'Intervals and steady pace',
      30,
      imgRun,
      [red, const Color(0xFF8B2A2A)],
      [
        PlanExercise('Warm-up jog', 1, 5, unit: 'min'),
        PlanExercise('Fast intervals', 6, 1, unit: 'min'),
        PlanExercise('Steady run', 1, 12, unit: 'min'),
        PlanExercise('Cool-down walk', 1, 5, unit: 'min'),
      ],
    ),
    'Yoga flow': WorkoutPlan(
      'Yoga flow',
      'Mobility and balance',
      25,
      imgYoga,
      [const Color(0xFF7C5CD6), const Color(0xFF3B2A7A)],
      [
        PlanExercise('Sun salutation', 3, 5),
        PlanExercise('Warrior pose', 2, 40, unit: 'sec'),
        PlanExercise('Downward dog', 3, 45, unit: 'sec'),
        PlanExercise('Child pose', 1, 60, unit: 'sec'),
      ],
    ),
  };

  String planKey = 'Arms workout';
  WorkoutPlan get plan => plans[planKey]!;

  // ---------- Form keys and controllers ----------
  final stepsForm = GlobalKey<FormState>();
  final workoutForm = GlobalKey<FormState>();
  final bmiForm = GlobalKey<FormState>();

  final stepsCtrl = TextEditingController();
  final minutesCtrl = TextEditingController();
  final caloriesCtrl = TextEditingController();

  // Empty BMI fields
  final heightCtrl = TextEditingController();
  final weightCtrl = TextEditingController();

  String? workoutType;

  @override
  void dispose() {
    for (final c in [
      stepsCtrl,
      minutesCtrl,
      caloriesCtrl,
      heightCtrl,
      weightCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------- Derived values ----------
  List<Workout> get todayWorkouts =>
      workouts.where((w) => w.daysAgo == 0).toList();

  int get activeMinutes =>
      todayWorkouts.fold(0, (a, w) => a + w.minutes);

  int get calories =>
      (steps * 0.04).round() +
          todayWorkouts.fold(0, (a, w) => a + w.calories);

  double get distanceKm => steps * 0.00075;

  List<double> get weeklySteps =>
      [8200, 10400, 7600, 11200, 9300, 5600, steps.toDouble()];

  List<String> get weeklyLabels {
    const d = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();

    return List.generate(
      7,
          (i) => i == 6
          ? 'Today'
          : d[now.subtract(Duration(days: 6 - i)).weekday - 1],
    );
  }

  List<double> get monthlyAverages {
    return [
      7900,
      8600,
      9100,
      weeklySteps.reduce((a, b) => a + b) / 7,
    ];
  }

  // ---------- Actions ----------
  void msg(String m) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(m),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void addStepsAmount(int n) {
    setState(() => steps += n);
  }

  void submitSteps() {
    if (!stepsForm.currentState!.validate()) return;

    final n = int.parse(stepsCtrl.text.trim());

    addStepsAmount(n);
    stepsCtrl.clear();

    msg('Added ${fmt(n)} steps');
  }

  void submitWorkout() {
    if (!workoutForm.currentState!.validate()) return;

    final mins = int.parse(minutesCtrl.text.trim());

    final kcal = int.tryParse(caloriesCtrl.text.trim()) ??
        mins * caloriesPerMinute[workoutType]!;

    setState(() {
      workouts.insert(
        0,
        Workout(workoutType!, mins, kcal, 0),
      );

      workoutType = null;
    });

    minutesCtrl.clear();
    caloriesCtrl.clear();

    workoutForm.currentState!.reset();

    msg('Workout saved: $mins min, $kcal kcal');
  }

  void finishPlan() {
    final p = plan;

    if (p.doneCount == 0) return;

    final mins = math.max(1, (p.minutes * p.progress).round());
    final kcal = mins * (caloriesPerMinute[p.name] ?? 6);

    setState(() {
      workouts.insert(0, Workout(p.name, mins, kcal, 0));

      for (final e in p.exercises) {
        e.done = false;
      }
    });

    msg('${p.name} logged: $mins min, $kcal kcal');
  }

  void calculateBmi() {
    if (!bmiForm.currentState!.validate()) return;

    final h = double.parse(heightCtrl.text.trim()) / 100;
    final w = double.parse(weightCtrl.text.trim());

    setState(() => bmi = w / (h * h));
  }

  // ---------- Layout ----------
  static const items = [
    NavItem(Icons.home_outlined, Icons.home, 'Home'),
    NavItem(Icons.directions_walk_outlined, Icons.directions_walk, 'Activity'),
    NavItem(Icons.fitness_center_outlined, Icons.fitness_center, 'Workouts'),
    NavItem(Icons.bar_chart_outlined, Icons.bar_chart, 'Progress'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget content;

    switch (tab) {
      case 0:
        content = homePage();
        break;
      case 1:
        content = activityPage();
        break;
      case 2:
        content = workoutsPage();
        break;
      default:
        content = progressPage();
    }

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(
        key: ValueKey(tab),
        child: content,
      ),
    );

    if (width >= 800) {
      final extended = width >= 1100;

      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: extended,
              backgroundColor: Colors.white,
              selectedIndex: tab,
              onDestinationSelected: (i) =>
                  setState(() => tab = i),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white),
                    ),
                    if (extended) ...[
                      const SizedBox(width: 10),
                      const Text(
                        'FitTrack',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              destinations: [
                for (final it in items)
                  NavigationRailDestination(
                    icon: Icon(it.icon),
                    selectedIcon: Icon(it.selected),
                    label: Text(it.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: tab,
        onDestinationSelected: (i) =>
            setState(() => tab = i),
        destinations: [
          for (final it in items)
            NavigationDestination(
              icon: Icon(it.icon),
              selectedIcon: Icon(it.selected),
              label: it.label,
            ),
        ],
      ),
    );
  }

  Widget page(Widget child) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: child,
        ),
      ),
    ),
  );

  Widget heading(String title, String sub) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
      ),
      const SizedBox(height: 4),
      Text(sub, style: TextStyle(color: ink.withOpacity(.6))),
      const SizedBox(height: 20),
    ],
  );

  Widget section(String t) => Padding(
    padding: const EdgeInsets.only(top: 26, bottom: 12),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: ink,
      ),
    ),
  );

  Widget card(
      Widget child, {
        EdgeInsets padding = const EdgeInsets.all(20),
      }) =>
      Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE3E7F2)),
          boxShadow: [
            BoxShadow(
              color: ink.withOpacity(.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: child,
      );

  // ---------- Reusable pieces ----------
  Widget photo(String url, List<Color> fallback) => Image.network(
    url,
    fit: BoxFit.cover,
    loadingBuilder: (c, child, p) =>
    p == null ? child : gradientBox(fallback),
    errorBuilder: (c, e, s) => gradientBox(fallback),
  );

  Widget gradientBox(List<Color> colors) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  );

  Widget bar(double value, Color color, {double height = 10}) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: Stack(
          children: [
            Container(height: height, color: color.withOpacity(.14)),
            TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0,
                end: value.clamp(0.0, 1.0),
              ),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (c, v, _) => FractionallySizedBox(
                widthFactor: v,
                child: Container(height: height, color: color),
              ),
            ),
          ],
        ),
      );

  Widget labeledBar(
      String label,
      String detail,
      double value,
      Color color,
      ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
              Text(
                detail,
                style: TextStyle(color: ink.withOpacity(.6)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          bar(value, color, height: 10),
        ],
      );

  Widget stat(
      String title,
      String value,
      IconData icon,
      Color color, {
        double? progress,
      }) =>
      card(
        padding: const EdgeInsets.all(14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(color: ink.withOpacity(.6), fontSize: 13),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              bar(progress, color, height: 6),
            ],
          ],
        ),
      );

  Widget statGrid(List<Widget> children, {double height = 130}) =>
      GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisExtent: height,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        children: children,
      );

  Widget ring() => LayoutBuilder(
    builder: (context, box) {
      final remaining = stepGoal - steps;

      final r = TweenAnimationBuilder<double>(
        tween: Tween(
          begin: 0,
          end: (steps / stepGoal).clamp(0.0, 1.0),
        ),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (c, v, _) => SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(170, 170),
                painter: RingPainter(v, primary),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fmt(steps),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                  Text(
                    'of ${fmt(stepGoal)} steps',
                    style: TextStyle(
                      fontSize: 12,
                      color: ink.withOpacity(.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      final bars = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labeledBar(
            'Calories',
            '$calories / $calorieGoal kcal',
            calories / calorieGoal,
            red,
          ),
          const SizedBox(height: 18),
          labeledBar(
            'Active time',
            '$activeMinutes / $minuteGoal min',
            activeMinutes / minuteGoal,
            teal,
          ),
          const SizedBox(height: 18),
          Text(
            remaining <= 0
                ? 'Step goal reached. Nice work.'
                : '${fmt(remaining)} steps to go today.',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
        ],
      );

      return card(
        box.maxWidth >= 560
            ? Row(
          children: [
            r,
            const SizedBox(width: 32),
            Expanded(child: bars),
          ],
        )
            : Column(
          children: [
            r,
            const SizedBox(height: 20),
            bars,
          ],
        ),
      );
    },
  );

  Widget workoutTile(Workout w) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(
      backgroundColor: primary.withOpacity(.12),
      foregroundColor: primary,
      child: Icon(iconFor(w.name)),
    ),
    title: Text(
      w.name,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: ink,
      ),
    ),
    subtitle: Text('${w.minutes} min  |  ${w.calories} kcal'),
    trailing: Text(
      w.when,
      style: TextStyle(color: ink.withOpacity(.55), fontSize: 12),
    ),
  );

  IconData iconFor(String n) {
    switch (n) {
      case 'Running':
      case 'Cardio run':
        return Icons.directions_run;
      case 'Cycling':
        return Icons.directions_bike;
      case 'Swimming':
        return Icons.pool;
      case 'Walking':
        return Icons.directions_walk;
      case 'HIIT':
        return Icons.bolt;
      case 'Yoga':
      case 'Yoga flow':
        return Icons.self_improvement;
      case 'Core':
        return Icons.accessibility_new;
      default:
        return Icons.fitness_center;
    }
  }

  // ---------- Workout plan picker ----------
  Widget planPicker() => SizedBox(
    height: 170,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemBuilder: (context, i) {
        final key = plans.keys.elementAt(i);
        final p = plans[key]!;
        final selected = key == planKey;

        return GestureDetector(
          onTap: () => setState(() => planKey = key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 220,
            padding: EdgeInsets.all(selected ? 3 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selected ? primary : Colors.transparent,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(selected ? 20 : 22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  photo(p.image, p.colors),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xE6101A3F),
                          Color(0x1A101A3F),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${p.minutes} min  |  ${p.exercises.length} exercises',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        radius: 13,
                        backgroundColor: primary,
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  // ---------- Workout checklist ----------
  Widget planChecklist() {
    final p = plan;

    return card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          Text(
            '${p.focus}  |  about ${p.minutes} min',
            style: TextStyle(color: ink.withOpacity(.65)),
          ),
          const SizedBox(height: 16),
          labeledBar(
            'Progress',
            '${p.doneCount} of ${p.exercises.length} done',
            p.progress,
            teal,
          ),
          const SizedBox(height: 8),
          for (final e in p.exercises)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              value: e.done,
              onChanged: (v) => setState(() => e.done = v ?? false),
              title: Text(
                e.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: e.done ? ink.withOpacity(.45) : ink,
                  decoration: e.done ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text('${e.sets} sets x ${e.reps} ${e.unit}'),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: p.doneCount == 0 ? null : finishPlan,
              icon: const Icon(Icons.check),
              label: const Text('Finish and log workout'),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Home page ----------
  Widget homePage() {
    final hour = DateTime.now().hour;
    final greet =
    hour < 12 ? 'morning' : (hour < 17 ? 'afternoon' : 'evening');

    final recent = workouts.take(3).toList();

    return page(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SizedBox(
              height: 230,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  photo(imgHero, [primary, deep]),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topRight,
                        colors: [
                          Color(0xF2101A3F),
                          Color(0x40101A3F),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good $greet, Fitness Enthusiast!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Today's focus: ${plan.name}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primary,
                          ),
                          onPressed: () => setState(() => tab = 2),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Start workout'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          section("Today's activity"),
          ring(),
          const SizedBox(height: 14),
          statGrid([
            stat('Steps', fmt(steps), Icons.directions_walk, primary),
            stat('Calories', '$calories kcal',
                Icons.local_fire_department, red),
            stat('Distance', '${distanceKm.toStringAsFixed(2)} km',
                Icons.route, orange),
            stat('Active time', '$activeMinutes min', Icons.timer, teal),
          ], height: 128),
          section('Choose your workout'),
          planPicker(),
          section('Recent workouts'),
          card(
            recent.isEmpty
                ? const Text('No workouts yet. Add one in the Workouts tab.')
                : Column(
              children: [
                for (final w in recent) workoutTile(w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Activity page ----------
  Widget activityPage() {
    final bmiWidget = card(
      Form(
        key: bmiForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: heightCtrl,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      prefixIcon: Icon(Icons.height),
                    ),
                    validator: (v) => rangeCheck(v, 100, 250, 'Height'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: weightCtrl,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      prefixIcon:
                      Icon(Icons.monitor_weight_outlined),
                    ),
                    validator: (v) => rangeCheck(v, 25, 300, 'Weight'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: calculateBmi,
                child: const Text('Calculate BMI'),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              child: bmi == null
                  ? const SizedBox(width: double.infinity)
                  : bmiResult(bmi!),
            ),
          ],
        ),
      ),
    );

    return page(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('My activity', "Progress toward today's goals"),
          statGrid([
            stat('Steps', fmt(steps), Icons.directions_walk, primary,
                progress: steps / stepGoal),
            stat('Calories', '$calories kcal',
                Icons.local_fire_department, red,
                progress: calories / calorieGoal),
            stat('Distance', '${distanceKm.toStringAsFixed(2)} km',
                Icons.route, orange,
                progress: distanceKm / (stepGoal * 0.00075)),
            stat('Active time', '$activeMinutes min', Icons.timer, teal,
                progress: activeMinutes / minuteGoal),
          ], height: 156),
          section('Log steps'),
          card(
            Form(
              key: stepsForm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final n in [500, 1000, 2500])
                        ActionChip(
                          label: Text('+${fmt(n)}'),
                          onPressed: () => addStepsAmount(n),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: stepsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Steps to add',
                            prefixIcon: Icon(Icons.add),
                          ),
                          validator: (v) {
                            final n = int.tryParse((v ?? '').trim());
                            if (n == null) return 'Enter a whole number';
                            if (n < 1 || n > 50000) {
                              return 'Enter between 1 and 50,000';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => submitSteps(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: submitSteps,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          section('BMI calculator'),
          bmiWidget,
        ],
      ),
    );
  }

  String? rangeCheck(
      String? v,
      double min,
      double max,
      String what,
      ) {
    final n = double.tryParse((v ?? '').trim());

    if (n == null) return 'Enter your ${what.toLowerCase()}';
    if (n < min || n > max) {
      return '$what must be ${min.toInt()} to ${max.toInt()}';
    }

    return null;
  }

  Widget bmiResult(double b) {
    final frac = (b.clamp(15.0, 40.0) - 15) / 25;

    final cat = b < 18.5
        ? 'Underweight'
        : (b < 25
        ? 'Healthy weight'
        : (b < 30 ? 'Overweight' : 'Obese'));

    final col = b < 18.5
        ? orange
        : (b < 25 ? teal : (b < 30 ? orange : red));

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            b.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: col,
            ),
          ),
          Text(
            cat,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, box) {
              return SizedBox(
                height: 36,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 18,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 35,
                              child: Container(height: 12, color: orange),
                            ),
                            Expanded(
                              flex: 65,
                              child: Container(height: 12, color: teal),
                            ),
                            Expanded(
                              flex: 50,
                              child: Container(
                                height: 12,
                                color: orange.withOpacity(.6),
                              ),
                            ),
                            Expanded(
                              flex: 100,
                              child: Container(height: 12, color: red),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      left: (box.maxWidth - 28) * frac,
                      top: 0,
                      child: const Icon(
                        Icons.arrow_drop_down,
                        size: 28,
                        color: ink,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('15', style: TextStyle(fontSize: 11)),
              Text('18.5', style: TextStyle(fontSize: 11)),
              Text('25', style: TextStyle(fontSize: 11)),
              Text('30', style: TextStyle(fontSize: 11)),
              Text('40', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Workouts page ----------
  Widget workoutsPage() {
    final form = card(
      Form(
        key: workoutForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a workout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: workoutType,
              decoration: const InputDecoration(labelText: 'Exercise'),
              items: [
                for (final k in caloriesPerMinute.keys)
                  DropdownMenuItem(value: k, child: Text(k)),
              ],
              onChanged: (v) => setState(() => workoutType = v),
              validator: (v) =>
              v == null ? 'Choose an exercise' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: minutesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
              ),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null) return 'Enter the duration in minutes';
                if (n < 1 || n > 300) {
                  return 'Enter between 1 and 300 minutes';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: caloriesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calories burned',
                helperText: 'Leave blank to estimate',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;

                final n = int.tryParse(v.trim());

                if (n == null || n < 1 || n > 3000) {
                  return 'Enter between 1 and 3,000 kcal';
                }

                return null;
              },
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: submitWorkout,
                icon: const Icon(Icons.add),
                label: const Text('Save workout'),
              ),
            ),
          ],
        ),
      ),
    );

    final history = card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          const SizedBox(height: 6),
          if (workouts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No workouts yet. Save your first one with the form.',
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: workouts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final w = workouts[i];

                return Dismissible(
                  key: ObjectKey(w),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) => setState(() => workouts.remove(w)),
                  child: workoutTile(w),
                );
              },
            ),
          if (workouts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Swipe a workout left to delete it.',
                style: TextStyle(
                  fontSize: 12,
                  color: ink.withOpacity(.55),
                ),
              ),
            ),
        ],
      ),
    );

    return page(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('Workouts', "${todayWorkouts.length} logged today"),
          planPicker(),
          const SizedBox(height: 16),
          planChecklist(),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, box) {
              if (box.maxWidth >= 820) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: form),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: history),
                  ],
                );
              }

              return Column(
                children: [
                  form,
                  const SizedBox(height: 16),
                  history,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------- Progress page ----------
  Widget progressPage() {
    final values = weekly ? weeklySteps : monthlyAverages;

    final labels = weekly
        ? weeklyLabels
        : ['Wk 1', 'Wk 2', 'Wk 3', 'This wk'];

    final avg = values.reduce((a, b) => a + b) / values.length;
    final best = values.reduce(math.max);
    final hit = values.where((v) => v >= stepGoal).length;
    final maxV = math.max(stepGoal.toDouble(), best);

    Widget slider(
        String label,
        IconData icon,
        Color color,
        double value,
        double min,
        double max,
        int div,
        String unit,
        ValueChanged<double> onChanged,
        ) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ),
                Text(
                  '${fmt(value)} $unit',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: div,
              activeColor: color,
              onChanged: onChanged,
            ),
          ],
        );

    return page(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading(
            'Progress',
            weekly
                ? 'Daily steps this week'
                : 'Average daily steps per week',
          ),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Weekly'),
                icon: Icon(Icons.view_week_outlined),
              ),
              ButtonSegment(
                value: false,
                label: Text('Monthly'),
                icon: Icon(Icons.calendar_month_outlined),
              ),
            ],
            selected: {weekly},
            onSelectionChanged: (v) =>
                setState(() => weekly = v.first),
          ),
          const SizedBox(height: 16),
          card(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 230,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < values.length; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  values[i] >= 1000
                                      ? '${(values[i] / 1000).toStringAsFixed(1)}k'
                                      : values[i].toStringAsFixed(0),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                TweenAnimationBuilder<double>(
                                  key: ValueKey('${weekly}_$i'),
                                  tween: Tween(
                                    begin: 0,
                                    end: values[i] / maxV,
                                  ),
                                  duration: Duration(
                                    milliseconds: 600 + i * 90,
                                  ),
                                  curve: Curves.easeOutCubic,
                                  builder: (c, v, _) => Container(
                                    height: 160 * v,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: values[i] >= stepGoal
                                            ? [
                                          teal,
                                          const Color(0xFF0B7F75),
                                        ]
                                            : [primary, deep],
                                      ),
                                      borderRadius:
                                      const BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  labels[i],
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: teal,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Met the ${fmt(stepGoal)}-step goal',
                      style: TextStyle(
                        fontSize: 12,
                        color: ink.withOpacity(.65),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          section('Summary'),
          statGrid([
            stat('Average', '${fmt(avg)} steps',
                Icons.show_chart, primary),
            stat('Best', '${fmt(best)} steps',
                Icons.emoji_events_outlined, orange),
            stat('Goal met', '$hit of ${values.length}',
                Icons.check_circle_outline, teal),
          ], height: 128),
          section('Daily goals'),
          card(
            Column(
              children: [
                slider(
                  'Steps',
                  Icons.directions_walk,
                  primary,
                  stepGoal.toDouble(),
                  2000,
                  25000,
                  23,
                  'steps',
                      (v) => setState(() => stepGoal = v.round()),
                ),
                slider(
                  'Calories',
                  Icons.local_fire_department,
                  red,
                  calorieGoal.toDouble(),
                  100,
                  1500,
                  28,
                  'kcal',
                      (v) => setState(() => calorieGoal = v.round()),
                ),
                slider(
                  'Active time',
                  Icons.timer,
                  teal,
                  minuteGoal.toDouble(),
                  10,
                  180,
                  34,
                  'min',
                      (v) => setState(() => minuteGoal = v.round()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Custom progress ring ----------
class RingPainter extends CustomPainter {
  RingPainter(this.progress, this.color);

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 15.0;

    final rect = (Offset.zero & size).deflate(stroke / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color.withOpacity(.14);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [color, teal],
      ).createShader(rect);

    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      old.progress != progress || old.color != color;
}
