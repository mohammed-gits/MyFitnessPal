import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/body_stat.dart';

class BodyStatsScreen extends StatefulWidget {
  const BodyStatsScreen({super.key});

  @override
  State<BodyStatsScreen> createState() => _BodyStatsScreenState();
}

class _BodyStatsScreenState extends State<BodyStatsScreen> {
  final _weightCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();

  List<BodyStat> _entries = [];
  bool _loading = true;

  String _goal = 'lose';
  String _activity = 'light';
  bool _reminder = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _waistCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('body_stats');
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _entries = list
          .map((e) => BodyStat.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _entries.map((e) => e.toMap()).toList();
    await prefs.setString('body_stats', jsonEncode(data));
  }

  void _saveToday() async {
    double? parse(String s) {
      final t = s.trim();
      if (t.isEmpty) return null;
      return double.tryParse(t);
    }

    final weight = parse(_weightCtrl.text);
    final waist = parse(_waistCtrl.text);
    if (weight == null && waist == null) return;

    final entry = BodyStat(date: DateTime.now(), weight: weight, waist: waist);
    setState(() => _entries.insert(0, entry));
    await _saveEntries();
    _weightCtrl.clear();
    _waistCtrl.clear();
  }

  void _deleteEntry(int index) async {
    setState(() => _entries.removeAt(index));
    await _saveEntries();
  }

  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString().padLeft(2, '0');
    return '$day/$month/$year';
  }

  Widget _todayCard(BuildContext context) {
    final theme = Theme.of(context);
    InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.black.withOpacity(0.02),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's measurements",
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weightCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: deco('Weight (kg)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _waistCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: deco('Waist (cm)'),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _saveToday,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your goal & settings',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _goal,
              decoration: const InputDecoration(labelText: 'Goal'),
              items: const [
                DropdownMenuItem(value: 'lose', child: Text('Lose weight')),
                DropdownMenuItem(value: 'maintain', child: Text('Maintain')),
                DropdownMenuItem(value: 'gain', child: Text('Gain muscle')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _goal = v);
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _activity,
              decoration: const InputDecoration(labelText: 'Activity level'),
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                DropdownMenuItem(value: 'intense', child: Text('Intense')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _activity = v);
              },
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Daily reminder to log stats'),
              value: _reminder,
              onChanged: (v) => setState(() => _reminder = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _latestCard(BuildContext context) {
    final theme = Theme.of(context);
    if (_entries.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "No progress yet.\nSave today's measurements to see them here.",
            style:
                theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ),
      );
    }
    final e = _entries.first;
    final w = e.weight != null ? '${e.weight!.toStringAsFixed(1)} kg' : '-';
    final ws = e.waist != null ? '${e.waist!.toStringAsFixed(1)} cm' : '-';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest progress',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Weight: $w • Waist: $ws',
                style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _historyCard(BuildContext context) {
    final theme = Theme.of(context);
    if (_entries.isEmpty) return const SizedBox.shrink();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'History',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Column(
              children: List.generate(_entries.length, (i) {
                final e = _entries[i];
                final w =
                    e.weight != null ? '${e.weight!.toStringAsFixed(1)} kg' : '-';
                final ws =
                    e.waist != null ? '${e.waist!.toStringAsFixed(1)} cm' : '-';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        _formatDate(e.date),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$w • $ws',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _deleteEntry(i),
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Body stats')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _todayCard(context),
            const SizedBox(height: 16),
            _goalCard(context),
            const SizedBox(height: 16),
            _latestCard(context),
            const SizedBox(height: 16),
            _historyCard(context),
          ],
        ),
      ),
    );
  }
}
