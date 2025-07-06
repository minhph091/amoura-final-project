export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
  errors?: Record<string, string[]>;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}

export interface PaginationParams {
  page?: number;
  limit?: number;
}

export interface SortParams {
  sortBy?: string;
  sortOrder?: "asc" | "desc";
}

export interface DateRange {
  from: Date;
  to: Date;
}

export interface BaseFilters extends PaginationParams, SortParams {
  search?: string;
}

export interface ApiError {
  message: string;
  code?: string;
  status?: number;
  details?: unknown;
}

export interface DashboardStats {
  users: {
    total: number;
    active: number;
    newThisMonth: number;
    growth: number;
  };
  moderators: {
    total: number;
    active: number;
    online: number;
    growth: number;
  };
  reports: {
    total: number;
    pending: number;
    resolved: number;
    trend: number;
  };
  matches: {
    total: number;
    thisMonth: number;
    successRate: number;
    growth: number;
  };
  revenue: {
    thisMonth: number;
    lastMonth: number;
    growth: number;
    subscriptions: number;
  };
}
