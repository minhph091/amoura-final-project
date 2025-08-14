export interface Report {
  id: string;
  reporter: ReportUser;
  reported: ReportUser;
  type: ReportType;
  category: ReportCategory;
  description: string;
  status: ReportStatus;
  date: string;
  assignedTo?: string;
  resolvedAt?: string;
  resolvedBy?: string;
  resolutionNotes?: string;
  severity: ReportSeverity;
  attachments?: ReportAttachment[];
}

export interface ReportUser {
  id: string;
  name: string;
  avatar: string;
  initials: string;
}

export type ReportType =
  | "inappropriate_content"
  | "harassment"
  | "fake_profile"
  | "spam"
  | "other";
export type ReportCategory =
  | "profile"
  | "message"
  | "behavior"
  | "photo"
  | "safety";
export type ReportStatus =
  | "pending"
  | "investigating"
  | "resolved"
  | "dismissed"
  | "escalated";
export type ReportSeverity = "low" | "medium" | "high" | "critical";

export interface ReportAttachment {
  id: string;
  type: "image" | "screenshot" | "document";
  url: string;
  fileName: string;
  uploadedAt: string;
}

export interface CreateReportRequest {
  reporterId: string;
  reportedId: string;
  type: ReportType;
  category: ReportCategory;
  description: string;
  severity: ReportSeverity;
  attachments?: File[];
}

export interface UpdateReportRequest {
  status?: ReportStatus;
  assignedTo?: string;
  resolutionNotes?: string;
  severity?: ReportSeverity;
}

export interface ReportFilters {
  search?: string;
  status?: ReportStatus | "all";
  type?: ReportType | "all";
  category?: ReportCategory | "all";
  severity?: ReportSeverity | "all";
  assignedTo?: string | "all";
  dateRange?: {
    from: Date;
    to: Date;
  };
  sortBy?: "date" | "severity" | "status" | "type";
  sortOrder?: "asc" | "desc";
}

export interface ReportStats {
  totalReports: number;
  pendingReports: number;
  resolvedReports: number;
  escalatedReports: number;
  averageResolutionTime: number;
  reportsByType: Record<ReportType, number>;
  reportsBySeverity: Record<ReportSeverity, number>;
}
