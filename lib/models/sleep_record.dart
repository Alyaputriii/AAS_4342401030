class SleepRecord {
  final int? id;
  final DateTime bedTime;
  final DateTime wakeTime;
  final String quality; // 'Buruk', 'Cukup', 'Baik', 'Sangat Baik'
  final String? notes;

  SleepRecord({
    this.id,
    required this.bedTime,
    required this.wakeTime,
    required this.quality,
    this.notes,
  });

  // Hitung durasi tidur dalam jam
  double get duration {
    return wakeTime.difference(bedTime).inMinutes / 60;
  }

  // Konversi ke Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'quality': quality,
      'notes': notes,
    };
  }

  // Buat dari Map database
  factory SleepRecord.fromMap(Map<String, dynamic> map) {
    return SleepRecord(
      id: map['id'],
      bedTime: DateTime.parse(map['bedTime']),
      wakeTime: DateTime.parse(map['wakeTime']),
      quality: map['quality'],
      notes: map['notes'],
    );
  }

  // Format durasi untuk tampilan
  String get formattedDuration {
    int hours = duration.floor();
    int minutes = ((duration - hours) * 60).round();
    return '$hours jam $minutes menit';
  }
}