import type {
  UserStatus,
  Gender,
  ModeratorStatus,
  ModeratorRole,
  ReportType,
  ReportCategory,
  ReportStatus,
  ReportSeverity,
  MessageStatus,
  MessageType,
} from "../types";

export const VALIDATION_RULES = {
  EMAIL: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  PASSWORD: {
    MIN_LENGTH: 8,
    PATTERN: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
    MESSAGE:
      "Password must contain at least 8 characters with uppercase, lowercase, number and special character",
  },
  NAME: {
    MIN_LENGTH: 2,
    MAX_LENGTH: 50,
    PATTERN: /^[a-zA-Z\s'-]+$/,
  },
  AGE: {
    MIN: 18,
    MAX: 100,
  },
} as const;

export const USER_STATUSES: Record<UserStatus, string> = {
  active: "Active",
  suspended: "Suspended",
  pending: "Pending",
  blocked: "Blocked",
} as const;

export const GENDERS: Record<Gender, string> = {
  male: "Male",
  female: "Female",
  other: "Other",
  prefer_not_to_say: "Prefer not to say",
} as const;

export const MODERATOR_STATUSES: Record<ModeratorStatus, string> = {
  active: "Active",
  disabled: "Disabled",
  suspended: "Suspended",
} as const;

export const MODERATOR_ROLES: Record<ModeratorRole, string> = {
  moderator: "Moderator",
  senior_moderator: "Senior Moderator",
  admin: "Admin",
} as const;

export const REPORT_TYPES: Record<ReportType, string> = {
  inappropriate_content: "Inappropriate Content",
  harassment: "Harassment",
  fake_profile: "Fake Profile",
  spam: "Spam",
  other: "Other",
} as const;

export const REPORT_CATEGORIES: Record<ReportCategory, string> = {
  profile: "Profile",
  message: "Message",
  behavior: "Behavior",
  photo: "Photo",
  safety: "Safety",
} as const;

export const REPORT_STATUSES: Record<ReportStatus, string> = {
  pending: "Pending",
  investigating: "Investigating",
  resolved: "Resolved",
  dismissed: "Dismissed",
  escalated: "Escalated",
} as const;

export const REPORT_SEVERITIES: Record<ReportSeverity, string> = {
  low: "Low",
  medium: "Medium",
  high: "High",
  critical: "Critical",
} as const;

export const MESSAGE_STATUSES: Record<MessageStatus, string> = {
  sent: "Sent",
  delivered: "Delivered",
  read: "Read",
  failed: "Failed",
} as const;

export const MESSAGE_TYPES: Record<MessageType, string> = {
  text: "Text",
  image: "Image",
  gif: "GIF",
  voice: "Voice",
  video: "Video",
} as const;

export const STATUS_COLORS = {
  active: "bg-green-500",
  inactive: "bg-gray-500",
  suspended: "bg-red-500",
  pending: "bg-yellow-500",
  blocked: "bg-red-600",
  disabled: "bg-gray-600",
  resolved: "bg-green-600",
  investigating: "bg-blue-500",
  escalated: "bg-purple-500",
  dismissed: "bg-gray-400",
} as const;
