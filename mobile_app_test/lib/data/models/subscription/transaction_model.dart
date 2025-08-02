// lib/data/models/subscription/transaction_model.dart

// Model giao dịch (Transaction)
class TransactionModel {
  final int id;
  final int userId;
  final int cardId;
  final int planId;
  final String purchasePeriod; // monthly, yearly
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.cardId,
    required this.planId,
    required this.purchasePeriod,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });
}

enum TransactionStatus { success, failed }

TransactionStatus transactionStatusFromString(String value) {
  switch (value) {
    case 'success':
      return TransactionStatus.success;
    case 'failed':
      return TransactionStatus.failed;
    default:
      return TransactionStatus.failed;
  }
}
