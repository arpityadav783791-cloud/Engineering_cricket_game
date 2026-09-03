import '../../models/career_stats.dart';

/// Contract for Career Statistics persistence (Dependency Inversion Principle).
abstract class CareerStatsRepository {
  Future<CareerStats> getCareerStats();
  Future<void> saveCareerStats(CareerStats stats);
  Future<void> resetCareerStats();
}
