import 'dart:math';

class Workout {
  String id;
  String name;
  List<Exercise> exercises;

  Workout({
    required this.id,
    required this.name,
    List<Exercise>? exercises,
  }) : exercises = exercises ?? [];

  int get totalSets =>
      exercises.fold(0, (sum, e) => sum + e.sets);

  int get completedSets => exercises.fold(
    0,
        (sum, e) => sum + e.completedSets.where((d) => d).length,
  );

  // For saving to local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as String,
      name: map['name'] as String,
      exercises: (map['exercises'] as List<dynamic>?)
          ?.map((e) => Exercise.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class Exercise {
  String id;
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
  }) : completedSets = completedSets ?? List<bool>.filled(sets, false);

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
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      sets: map['sets'] as int,
      reps: map['reps'] as int,
      completedSets: (map['completedSets'] as List<dynamic>?)
          ?.map((e) => e as bool)
          .toList() ??
          List<bool>.filled(map['sets'] as int, false),
    );
  }

  static String generateId() {
    final random = Random();
    return '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}';
  }
}
