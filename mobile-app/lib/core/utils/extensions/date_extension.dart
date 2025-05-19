// lib/core/utils/extensions/date_extension.dart

// Hàm mở rộng cho DateTime
extension DateExtension on DateTime {
  /// Format date thành chuỗi "dd/MM/yyyy"
  String toDDMMYYYY() =>
      "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year";
}