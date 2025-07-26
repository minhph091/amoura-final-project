
import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type { ApiResponse } from "../types/common.types";
import type { User } from "../types/user.types";

export class UserService {
  async getCurrentUser(): Promise<ApiResponse<User>> {
    try {
      return await apiClient.get<User>(API_ENDPOINTS.USER.GET);
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to fetch user",
      };
    }
  }

  async isUserOnline(id: string): Promise<ApiResponse<boolean>> {
    try {
      return await apiClient.get<boolean>(API_ENDPOINTS.USER.ONLINE(id));
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to check user online status",
      };
    }
  }
}

export const userService = new UserService();
