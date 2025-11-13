class FitbitActivity {
  final int? steps;
  final double? distance;
  final int? calories;
  final DateTime date;

  FitbitActivity({
    this.steps,
    this.distance,
    this.calories,
    required this.date,
  });

  factory FitbitActivity.fromJson(Map<String, dynamic> json) {
    return FitbitActivity(
      steps: json['steps'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
      calories: json['calories'] as int?,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'distance': distance,
      'calories': calories,
      'date': date.toIso8601String(),
    };
  }
}

class FitbitSleep {
  final int? duration;
  final int? minutesAsleep;
  final int? minutesAwake;
  final DateTime date;

  FitbitSleep({
    this.duration,
    this.minutesAsleep,
    this.minutesAwake,
    required this.date,
  });

  factory FitbitSleep.fromJson(Map<String, dynamic> json) {
    return FitbitSleep(
      duration: json['duration'] as int?,
      minutesAsleep: json['minutesAsleep'] as int?,
      minutesAwake: json['minutesAwake'] as int?,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'minutesAsleep': minutesAsleep,
      'minutesAwake': minutesAwake,
      'date': date.toIso8601String(),
    };
  }
}

class FitbitHeartRate {
  final int? restingHeartRate;
  final DateTime date;

  FitbitHeartRate({
    this.restingHeartRate,
    required this.date,
  });

  factory FitbitHeartRate.fromJson(Map<String, dynamic> json) {
    return FitbitHeartRate(
      restingHeartRate: json['restingHeartRate'] as int?,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restingHeartRate': restingHeartRate,
      'date': date.toIso8601String(),
    };
  }
}
