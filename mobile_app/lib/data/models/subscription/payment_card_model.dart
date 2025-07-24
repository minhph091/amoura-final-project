// lib/data/models/subscription/payment_card_model.dart

// Model thẻ thanh toán (PaymentCard)
class PaymentCardModel {
  final int id;
  final int userId;
  final String cardNumbers;
  final String nameInCard;
  final DateTime expirationDate;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentCardModel({
    required this.id,
    required this.userId,
    required this.cardNumbers,
    required this.nameInCard,
    required this.expirationDate,
    required this.isDefault,
    required this.createdAt,
    this.updatedAt,
  });
}
