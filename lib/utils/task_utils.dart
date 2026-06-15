import '../models/task_schedule.dart';
import '../models/reptile.dart';

/// Calculates the number of tasks scheduled for today, given a list of schedules
/// and the list of current reptiles (for resolving "all" targetType schedules).
int calculateTodayTasks(List<TaskSchedule> schedules, List<Reptile> reptiles, {DateTime? evaluationDate}) {
  final evaluation = evaluationDate ?? DateTime.now();
  final evalWeekday = evaluation.weekday; // 1 = Monday, 7 = Sunday
  
  int count = 0;
  for (final schedule in schedules) {
    // Check if the evaluation date is after or equal to the startDate
    final startOnlyDate = DateTime(schedule.startDate.year, schedule.startDate.month, schedule.startDate.day);
    final evalOnlyDate = DateTime(evaluation.year, evaluation.month, evaluation.day);
    
    if (evalOnlyDate.isBefore(startOnlyDate)) {
      continue;
    }
    
    // Check if today matches the daysOfWeek
    if (schedule.daysOfWeek.contains(evalWeekday)) {
      bool isActive = true;
      if (schedule.intervalValue > 1) {
        if (schedule.intervalUnit == 'Weeks') {
          final daysDiff = evalOnlyDate.difference(startOnlyDate).inDays;
          final weeksDiff = (daysDiff / 7).floor();
          if (weeksDiff % schedule.intervalValue != 0) {
            isActive = false;
          }
        } else if (schedule.intervalUnit == 'Days') {
          final daysDiff = evalOnlyDate.difference(startOnlyDate).inDays;
          if (daysDiff % schedule.intervalValue != 0) {
            isActive = false;
          }
        } else if (schedule.intervalUnit == 'Months') {
          final monthsDiff = (evalOnlyDate.year - startOnlyDate.year) * 12 + evalOnlyDate.month - startOnlyDate.month;
          if (monthsDiff % schedule.intervalValue != 0) {
            isActive = false;
          }
        }
      }
      
      if (isActive) {
        final actionCount = schedule.actions.length;
        if (schedule.targetType == 'all') {
          count += actionCount * reptiles.length;
        } else {
          count += actionCount;
        }
      }
    }
  }
  return count;
}
