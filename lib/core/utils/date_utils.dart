class TaskDateUtils {
  const TaskDateUtils._();

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String formatHeaderDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final dayStr = '${date.day} ${_months[date.month - 1]}';
    if (isToday) {
      return 'Today, $dayStr';
    }
    return '${_weekdays[date.weekday - 1]}, $dayStr';
  }

  static String formatTaskDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]}';
  }

  static String getGroupingKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff > 1 && diff <= 7) return 'This week';
    if (diff < 0) return 'Overdue';
    return '${date.day}/${date.month}/${date.year}';
  }
}
