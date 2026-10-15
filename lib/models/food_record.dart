import 'package:isar/isar.dart';

part 'food_record.g.dart';

@collection
class FoodRecord {
  Id id = Isar.autoIncrement;

  late String foodName;
  late int calories;
  late double protein;
  late double carbs;
  late double fat;
  late DateTime date;
}
