import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type { ApiResponse } from "../types/common.types";

export interface AdminSettings {
  id: number;
  key: string;
  value: string;
  updatedAt: string;
}

export class SettingsService {
  async getSettings(): Promise<ApiResponse<AdminSettings[]>> {
    try {
      return await apiClient.get<AdminSettings[]>(
        API_ENDPOINTS.ADMIN.STATS + "/settings"
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to fetch settings",
        data: [],
      };
    }
  }

  async updateSetting(
    id: number,
    value: string
  ): Promise<ApiResponse<AdminSettings>> {
    try {
      return await apiClient.patch<AdminSettings>(
        API_ENDPOINTS.ADMIN.STATS + `/settings/${id}`,
        { value }
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to update setting",
      };
    }
  }
}

export const settingsService = new SettingsService();
