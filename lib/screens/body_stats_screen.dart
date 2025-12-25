import 'package:flutter/material.dart';

import '../services/body_stats_api.dart';
import '../services/settings_api.dart';

class BodyStatsScreen extends StatefulWidget {
  const BodyStatsScreen({super.key});

  @override
  State<BodyStatsScreen> createState() => _BodyStatsScreenState();
}

class _BodyStatsScreenState extends State<BodyStatsScreen> {
  bool _loading = true;

  List<Map<String, dynamic>> _entries = [];

  String _goal = "lose";
  String _activity = "light";
  bool _reminder = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final entries = await BodyStatsApi.fetchEntries();
      final settings = await SettingsApi.getSettings();

      if (!mounted) return;
      setState(() {
        _entries = entries;
        _goal = (settings["goal"] ?? "lose").toString();
        _activity = (settings["activity"] ?? "light").toString();
        _reminder = (settings["reminder"] == true);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load body stats")),
      );
    }
  }

  Future<void> _saveSettings() async {
    try {
      await SettingsApi.updateSettings(
        goal: _goal,
        activity: _activity,
        reminder: _reminder,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save settings")),
      );
    }
  }

  void _openAddEntryDialog() {
    final weightController = TextEditingController();
    final waistController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Add entry"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Weight (kg)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: waistController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Waist (cm)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              final w = double.tryParse(weightController.text.trim());
              final wa = double.tryParse(waistController.text.trim());

              if (w == null && wa == null) return;

              Navigator.pop(ctx);

              setState(() => _loading = true);
              try {
                await BodyStatsApi.createEntry(weight: w, waist: wa);
                await _loadAll();
              } catch (_) {
                if (!mounted) return;
                setState(() => _loading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to add entry")),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEntry(int id) async {
    setState(() => _loading = true);
    try {
      await BodyStatsApi.deleteEntry(id);
      await _loadAll();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete entry")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddEntryDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add entry"),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Text(
              "Body Stats",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "Track your progress",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Settings",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _goal,
                      decoration: const InputDecoration(labelText: "Goal"),
                      items: const [
                        DropdownMenuItem(value: "lose", child: Text("Lose weight")),
                        DropdownMenuItem(value: "maintain", child: Text("Maintain")),
                        DropdownMenuItem(value: "gain", child: Text("Gain weight")),
                      ],
                      onChanged: (v) async {
                        if (v == null) return;
                        setState(() => _goal = v);
                        await _saveSettings();
                      },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _activity,
                      decoration: const InputDecoration(labelText: "Activity"),
                      items: const [
                        DropdownMenuItem(value: "light", child: Text("Light")),
                        DropdownMenuItem(value: "moderate", child: Text("Moderate")),
                        DropdownMenuItem(value: "heavy", child: Text("Heavy")),
                      ],
                      onChanged: (v) async {
                        if (v == null) return;
                        setState(() => _activity = v);
                        await _saveSettings();
                      },
                    ),
                    const SizedBox(height: 12),

                    SwitchListTile(
                      value: _reminder,
                      onChanged: (v) async {
                        setState(() => _reminder = v);
                        await _saveSettings();
                      },
                      title: const Text("Reminder"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              "Entries",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            if (_entries.isEmpty)
              Text(
                "No entries yet. Tap 'Add entry'.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              )
            else
              ..._entries.map((e) {
                final id = (e["id"] as int?) ?? 0;
                final weight = e["weight"];
                final waist = e["waist"];
                final createdAt = (e["createdAt"] ?? "").toString();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        "Weight: ${weight ?? '-'}  |  Waist: ${waist ?? '-'}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        createdAt,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: id <= 0 ? null : () => _deleteEntry(id),
                      ),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
