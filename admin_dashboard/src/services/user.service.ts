import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type { ApiResponse } from "../types/common.types";
import type { User } from "../types/user.types";

export class UserService {
  async getUsers(filters?: any): Promise<ApiResponse<User[]>> {
    try {
      // Sử dụng endpoint thật từ backend: /users (GET all users)
      let endpoint = "/user/all";
      let params = "";
      if (filters) {
        const query = Object.entries(filters)
          .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(String(v))}`)
          .join("&");
        if (query) params = `?${query}`;
      }
      return await apiClient.get<User[]>(`${endpoint}${params}`);
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to fetch users",
      };
    }
  }
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

  async suspendUser(id: string): Promise<ApiResponse<any>> {
    try {
      // Assuming the backend endpoint is PATCH /users/:id/suspend
      return await apiClient.patch(`/users/${id}/suspend`);
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to suspend user",
      };
    }
  }
}

export const userService = new UserService();
