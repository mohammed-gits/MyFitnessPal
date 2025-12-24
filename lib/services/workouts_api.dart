import '../models/workout.dart';
import 'api.dart';

class WorkoutsApi {
  static Future<List<Workout>> fetchWorkouts() async {
    final data = await Api.getJson("/workouts/list.php");
    final list = (data["workouts"] as List?) ?? [];
    return list.map((e) => Workout.fromJson(e)).toList();
  }

  static Future<Workout> createWorkout(String name) async {
    final data = await Api.postJson("/workouts/create.php", {"name": name});
    return Workout(id: data["id"], name: data["name"], exercises: []);
  }

  static Future<void> deleteWorkout(int id) async {
    await Api.postJson("/workouts/delete.php", {"id": id});
  }

  static Future<void> createExercise({
    required int workoutId,
    required String name,
    required int sets,
    required int reps,
  }) async {
    await Api.postJson("/exercises/create.php", {
      "workoutId": workoutId,
      "name": name,
      "sets": sets,
      "reps": reps,
    });
  }

  static Future<void> updateExercise(Exercise ex) async {
    await Api.postJson("/exercises/update.php", {
      "id": ex.id,
      "name": ex.name,
      "sets": ex.sets,
      "reps": ex.reps,
      "completedSets": ex.completedSets,
    });
  }

  static Future<void> deleteExercise(int id) async {
    await Api.postJson("/exercises/delete.php", {"id": id});
  }
}
