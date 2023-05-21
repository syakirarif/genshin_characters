import 'package:intl/intl.dart';

String formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return '';

  var format = DateFormat('EEE, dd-MM-yyyy, h:mm a');

  return format.format(dateTime.toLocal());
}
