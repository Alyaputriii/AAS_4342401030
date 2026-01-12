class UserProfile {
  final String name;
  final int targetSleepHours;

  UserProfile({
    required this.name,
    required this.targetSleepHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'targetSleepHours': targetSleepHours,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      targetSleepHours: map['targetSleepHours'] ?? 8,
    );
  }
}