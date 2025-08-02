// lib/core/utils/extensions/date_extension.dart

// This extension adds a method to format DateTime objects into a specific string format.
extension DateExtension on DateTime {
  // Converts the DateTime to a string in the format "DD/MM/YYYY".
  String toDDMMYYYY() =>
      "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year";
}
