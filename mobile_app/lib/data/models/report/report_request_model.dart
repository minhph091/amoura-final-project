// lib/data/models/report/report_request_model.dart

// Model báo cáo người dùng (ReportRequest)
class ReportRequestModel {
  final int id;
  final int reporterId;
  final int reportedUserId;
  final ReportRequestType type;
  final String description;
  final ReportRequestStatus status;
  final DateTime? resolvedAt;
  final int? resolvedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReportRequestModel({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.type,
    required this.description,
    required this.status,
    this.resolvedAt,
    this.resolvedBy,
    required this.createdAt,
    this.updatedAt,
  });
}

enum ReportRequestType { fake, inappropriateContent }
enum ReportRequestStatus { pending, resolving, resolved }

ReportRequestType reportRequestTypeFromString(String value) {
  switch (value) {
    case 'fake':
      return ReportRequestType.fake;
    case 'inappropriate content':
      return ReportRequestType.inappropriateContent;
    default:
      return ReportRequestType.fake;
  }
}

ReportRequestStatus reportRequestStatusFromString(String value) {
  switch (value) {
    case 'pending':
      return ReportRequestStatus.pending;
    case 'resolving':
      return ReportRequestStatus.resolving;
    case 'resolved':
      return ReportRequestStatus.resolved;
    default:
      return ReportRequestStatus.pending;
  }
}