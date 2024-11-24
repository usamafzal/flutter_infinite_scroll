import 'package:intl/intl.dart';

String formatedDate(String date) {
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
  final timeAgo = getTimeAgo(dateFormat);

  return timeAgo;
}

String getTimeAgo(DateTime date) {
  final difference = DateTime.now().difference(date);

  if (difference.inHours < 1) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    return '${difference.inDays ~/ 7} weeks ago';
  } else if (difference.inDays < 365) {
    return '${difference.inDays ~/ 30} months ago';
  } else {
    return '${difference.inDays ~/ 365} years ago';
  }
}
