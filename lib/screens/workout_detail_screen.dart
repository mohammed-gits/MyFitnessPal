import 'package:flutter/material.dart';

import '../models/workout.dart';
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
              // small bar at top
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
                      decoration: const InputDecoration(
                        labelText: 'Sets',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reps per set',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final sets = int.tryParse(setsController.text) ?? 0;
                    final reps = int.tryParse(repsController.text) ?? 0;

                    if (name.isEmpty || sets <= 0 || reps <= 0) {
                      return;
                    }

                    setState(() {
                      workout.exercises.add(
                        Exercise(
                          id: Exercise.generateId(),
                          name: name,
                          sets: sets,
                          reps: reps,
                        ),
                      );
                    });

                    Navigator.of(ctx).pop();
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

  void _toggleSet(Exercise exercise, int setIndex) {
    setState(() {
      exercise.toggleSet(setIndex);
    });
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
    final progress =
    totalSets == 0 ? 0.0 : completedSets / totalSets; // 0.0 to 1.0

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
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
        onPressed: _openAddExerciseSheet,
        icon: const Icon(Icons.add),
        label: const Text('Exercise'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress card at top
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              style:
                              theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalSets == 0
                                  ? 'No sets yet'
                                  : '$completedSets / $totalSets sets done',
                              style:
                              theme.textTheme.bodyMedium?.copyWith(
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
            // Exercises list
            Expanded(
              child: workout.exercises.isEmpty
                  ? Center(
                child: Text(
                  'No exercises yet.\nTap the button below to add one.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
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
                          Text(
                            exercise.name,
                            style:
                            theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${exercise.sets} sets • ${exercise.reps} reps',
                            style:
                            theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              exercise.sets,
                                  (setIndex) {
                                final done = exercise
                                    .completedSets[setIndex];

                                return ChoiceChip(
                                  label:
                                  Text('Set ${setIndex + 1}'),
                                  selected: done,
                                  onSelected: (_) =>
                                      _toggleSet(exercise, setIndex),
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
