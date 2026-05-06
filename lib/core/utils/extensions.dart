import 'package:intl/intl.dart';

extension NumberFormatting on num {
  String toLocaleString() {
    return NumberFormat.decimalPattern('id-ID').format(this);
  }
}

extension DateFormatting on DateTime {
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 7) {
      return DateFormat('dd MMM yyyy').format(this);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}
