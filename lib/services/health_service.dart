import 'package:health/health.dart';

class HealthService {
  static final Health _health = Health();

  static Future<bool> requestPermissions() async {
    final types = [
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.WEIGHT,
      HealthDataType.NUTRITION,
    ];
    
    bool hasPermissions = await _health.requestAuthorization(types);
    return hasPermissions;
  }

  // Leer calorías quemadas hoy
  static Future<int> getBurnedCaloriesToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
      types: [HealthDataType.ACTIVE_ENERGY_BURNED], 
      startTime: startOfDay, 
      endTime: now
    );

    double totalCalories = 0;
    for (var point in data) {
      totalCalories += (point.value as NumericHealthValue).numericValue;
    }
    return totalCalories.toInt();
  }
}
