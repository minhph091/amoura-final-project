export interface Moderator {
  id: string;
  name: string;
  email: string;
  avatar: string;
  initials: string;
  status: ModeratorStatus;
  role: ModeratorRole;
  joinDate: string;
  reportsHandled: number;
  lastActive: string;
  permissions: ModeratorPermission[];
  isOnline?: boolean;
}

export type ModeratorStatus = "active" | "disabled" | "suspended";
export type ModeratorRole = "moderator" | "admin";

export interface ModeratorPermission {
  id: string;
  name: string;
  description: string;
  category: PermissionCategory;
}

export type PermissionCategory =
  | "users"
  | "reports"
  | "content"
  | "system"
  | "analytics";

export interface CreateModeratorRequest {
  name: string;
  email: string;
  role: ModeratorRole;
  permissions: string[];
}

export interface UpdateModeratorRequest
  extends Partial<Omit<Moderator, "id" | "joinDate">> {}

export interface ModeratorFilters {
  search?: string;
  status?: ModeratorStatus | "all";
  role?: ModeratorRole | "all";
  sortBy?: "name" | "joinDate" | "lastActive" | "reportsHandled";
  sortOrder?: "asc" | "desc";
}

export interface ModeratorStats {
  totalModerators: number;
  activeModerators: number;
  onlineModerators: number;
  averageReportsHandled: number;
}
