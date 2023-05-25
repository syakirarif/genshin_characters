import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return '';

  var format = DateFormat('EEE, dd-MM-yyyy, h:mm a');

  return format.format(dateTime.toLocal());
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
