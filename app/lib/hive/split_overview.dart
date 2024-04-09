import 'package:app/hive/exercise.dart';
import 'package:app/hive/split.dart';
import 'package:hive/hive.dart';

part 'split_overview.g.dart';

@HiveType(typeId: 16)
class SplitOverview extends HiveObject {
  @HiveField(0)
  Split split;

  @HiveField(1)
  List<Exercise> exercises;

  @HiveField(2)
  List<List<String>> repetitions;

  SplitOverview({
    required this.split,
    required this.exercises,
    required this.repetitions,
  });
}
