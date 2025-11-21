class BodyStat {
  final DateTime date;
  final double? weight;
  final double? waist;

  BodyStat({
    required this.date,
    this.weight,
    this.waist,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'waist': waist,
    };
  }

  factory BodyStat.fromMap(Map<String, dynamic> map) {
    return BodyStat(
      date: DateTime.parse(map['date'] as String),
      weight: (map['weight'] as num?)?.toDouble(),
      waist: (map['waist'] as num?)?.toDouble(),
    );
  }
}
