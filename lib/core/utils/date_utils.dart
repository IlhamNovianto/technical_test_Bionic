import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  static String timeAgo(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM dd').format(date);
    } catch (_) {
      return '';
    }
  }
}
