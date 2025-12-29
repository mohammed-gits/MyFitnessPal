import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../services/workouts_api.dart';
import 'timer_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  Workout get workout => widget.workout;

  bool _saving = false;

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _reloadFromServer() async {
    final list = await WorkoutsApi.fetchWorkouts();
    final updated = list.where((w) => w.id == workout.id).toList();
    if (updated.isEmpty) return;

    setState(() {
      workout.name = updated.first.name;
      workout.exercises
        ..clear()
        ..addAll(updated.first.exercises);
    });
  }

  Future<void> _addExercise({
    required String name,
    required int sets,
    required int reps,
  }) async {
    setState(() => _saving = true);
    try {
      await WorkoutsApi.createExercise(
        workoutId: workout.id,
        name: name,
        sets: sets,
        reps: reps,
      );
      await _reloadFromServer();
    } catch (e) {
      _toast("Add exercise failed: $e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateExerciseRemote(Exercise exercise) async {
    setState(() => _saving = true);
    try {
      await WorkoutsApi.updateExercise(exercise);
      await _reloadFromServer();
    } catch (e) {
      _toast("Update failed: $e");
      await _reloadFromServer();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteExerciseRemote(Exercise exercise) async {
    setState(() => _saving = true);
    try {
      await WorkoutsApi.deleteExercise(exercise.id);
      await _reloadFromServer();
    } catch (e) {
      _toast("Delete failed: $e");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openAddExerciseSheet() {
    final nameController = TextEditingController();
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                'Add exercise',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise name',
                  hintText: 'e.g. Bench Press',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Sets'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      keyboardType: TextInputType.number,
                      decoration:
                      const InputDecoration(labelText: 'Reps per set'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _saving
                      ? null
                      : () async {
                    final name = nameController.text.trim();
                    final sets = int.tryParse(setsController.text) ?? 0;
                    final reps = int.tryParse(repsController.text) ?? 0;

                    if (name.isEmpty || sets <= 0 || reps <= 0) return;

                    Navigator.of(ctx).pop();
                    await _addExercise(name: name, sets: sets, reps: reps);
                  },
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditExerciseSheet(Exercise exercise) {
    final nameController = TextEditingController(text: exercise.name);
    final setsController = TextEditingController(text: exercise.sets.toString());
    final repsController = TextEditingController(text: exercise.reps.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                'Edit exercise',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Exercise name'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Sets'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      keyboardType: TextInputType.number,
                      decoration:
                      const InputDecoration(labelText: 'Reps per set'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _saving
                          ? null
                          : () async {
                        Navigator.of(ctx).pop();

                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (d) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text("Delete exercise?"),
                            content: Text('Delete "${exercise.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(d, false),
                                child: const Text("Cancel"),
                              ),
                              FilledButton.tonal(
                                onPressed: () => Navigator.pop(d, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (ok == true) {
                          await _deleteExerciseRemote(exercise);
                        }
                      },
                      child: const Text("Delete"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving
                          ? null
                          : () async {
                        final name = nameController.text.trim();
                        final sets = int.tryParse(setsController.text) ?? 0;
                        final reps = int.tryParse(repsController.text) ?? 0;

                        if (name.isEmpty || sets <= 0 || reps <= 0) return;

                        // Keep completed sets length consistent
                        final completed = List<bool>.from(exercise.completedSets);
                        if (sets > completed.length) {
                          completed.addAll(List<bool>.filled(sets - completed.length, false));
                        } else if (sets < completed.length) {
                          completed.removeRange(sets, completed.length);
                        }

                        final updated = Exercise(
                          id: exercise.id,
                          name: name,
                          sets: sets,
                          reps: reps,
                          completedSets: completed,
                        );

                        Navigator.of(ctx).pop();
                        await _updateExerciseRemote(updated);
                      },
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleSet(Exercise exercise, int setIndex) {
    setState(() {
      exercise.toggleSet(setIndex);
    });
    // Save to server
    _updateExerciseRemote(exercise);
  }

  void _openRestTimer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RestTimerPage(initialSeconds: 45),
      ),
    );
  }

  void _finishWorkout() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalSets = workout.totalSets;
    final completedSets = workout.completedSets;
    final progress = totalSets == 0 ? 0.0 : completedSets / totalSets;

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          TextButton(
            onPressed: _finishWorkout,
            child: const Text(
              'Finish',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _openAddExerciseSheet,
        icon: const Icon(Icons.add),
        label: const Text('Exercise'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 28,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalSets == 0
                                  ? 'No sets yet'
                                  : '$completedSets / $totalSets sets done',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _openRestTimer,
                        icon: const Icon(Icons.timer),
                        label: const Text('Rest'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: workout.exercises.isEmpty
                  ? Center(
                child: Text(
                  'No exercises yet.\nTap the button below to add one.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: workout.exercises.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final exercise = workout.exercises[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  exercise.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: _saving ? null : () => _openEditExerciseSheet(exercise),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${exercise.sets} sets • ${exercise.reps} reps',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              exercise.sets,
                                  (setIndex) {
                                final done = exercise.completedSets[setIndex];

                                return ChoiceChip(
                                  label: Text('Set ${setIndex + 1}'),
                                  selected: done,
                                  onSelected: _saving ? null : (_) => _toggleSet(exercise, setIndex),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
