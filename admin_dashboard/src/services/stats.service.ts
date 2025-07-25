import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type { ApiResponse } from "../types/common.types";

export interface AdminStats {
  totalUsers: number;
  activeUsers: number;
  totalReports: number;
  resolvedReports: number;
  totalSubscriptions: number;
  activeSubscriptions: number;
  [key: string]: number;
}

export class StatsService {
  async getStats(): Promise<ApiResponse<AdminStats>> {
    try {
      return await apiClient.get<AdminStats>(API_ENDPOINTS.ADMIN.STATS);
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to fetch stats",
      };
    }
  }
}

export const statsService = new StatsService();
