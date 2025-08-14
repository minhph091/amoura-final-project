import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import { adminService } from "./admin.service";
import type { ApiResponse } from "../types/common.types";
import type { User } from "../types/user.types";
import type { UserManagementData, CursorPaginationResponse, UserStatusUpdateRequest } from "./admin.service";

export class UserService {
  // Admin endpoints - lấy danh sách users cho admin
  async getUsers(params?: {
    cursor?: number;
    limit?: number;
    direction?: "NEXT" | "PREVIOUS";
  }): Promise<ApiResponse<CursorPaginationResponse<UserManagementData>>> {
    return await adminService.getUsers(params);
  }

  async searchUsers(searchTerm: string, params?: {
    cursor?: number;
    limit?: number;
    direction?: "NEXT" | "PREVIOUS";
  }): Promise<ApiResponse<CursorPaginationResponse<UserManagementData>>> {
    return await adminService.searchUsers(searchTerm, params);
  }

  async getUserById(userId: string): Promise<ApiResponse<UserManagementData>> {
    return await adminService.getUserById(userId);
  }

  async updateUserStatus(
    userId: string,
    request: UserStatusUpdateRequest
  ): Promise<ApiResponse<any>> {
    return await adminService.updateUserStatus(userId, request);
  }

  // Current user endpoints
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

  // Legacy method - deprecated
  async suspendUser(id: string): Promise<ApiResponse<any>> {
    try {
      // Use new admin service instead
      return await this.updateUserStatus(id, {
        status: "SUSPEND",
        reason: "Suspended by admin",
        suspensionDays: 7
      });
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to suspend user",
      };
    }
  }
}

export const userService = new UserService();
