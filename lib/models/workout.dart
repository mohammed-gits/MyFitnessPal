import 'dart:math';

class Workout {
  int id;
  String name;
  List<Exercise> exercises;

  Workout({
    required this.id,
    required this.name,
    List<Exercise>? exercises,
  }) : exercises = exercises ?? [];

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets);

  int get completedSets =>
      exercises.fold(0, (sum, e) => sum + e.completedSets.where((d) => d).length);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: _toInt(map['id']),
      name: (map['name'] ?? '').toString(),
      exercises: (map['exercises'] as List<dynamic>?)
          ?.map((e) => Exercise.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class Exercise {
  int id;
  String name;
  int sets;
  int reps;
  List<bool> completedSets;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    List<bool>? completedSets,
  }) : completedSets = _normalizeCompleted(sets, completedSets);

  void toggleSet(int index) {
    if (index < 0 || index >= completedSets.length) return;
    completedSets[index] = !completedSets[index];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'completedSets': completedSets,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    final s = _toInt(map['sets']);
    return Exercise(
      id: _toInt(map['id']),
      name: (map['name'] ?? '').toString(),
      sets: s,
      reps: _toInt(map['reps']),
      completedSets: (map['completedSets'] as List<dynamic>?)
          ?.map((v) => v == true)
          .toList(),
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final s = _toInt(json['sets']);
    return Exercise(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      sets: s,
      reps: _toInt(json['reps']),
      completedSets: (json['completedSets'] as List<dynamic>?)
          ?.map((v) => v == true)
          .toList(),
    );
  }

  static List<bool> _normalizeCompleted(int sets, List<bool>? incoming) {
    final safeSets = sets < 0 ? 0 : sets;
    final list = (incoming ?? const []).toList();

    if (list.length == safeSets) return list;
    if (list.length > safeSets) return list.take(safeSets).toList();

    return [
      ...list,
      ...List<bool>.filled(safeSets - list.length, false),
    ];
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is double) return v.toInt();
    return 0;
  }

  static int generateId() {
    final random = Random();
    return (DateTime.now().millisecondsSinceEpoch % 2000000000) * 10000 +
        random.nextInt(9999);
  }
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is String) return int.tryParse(v) ?? 0;
  if (v is double) return v.toInt();
  return 0;
}
