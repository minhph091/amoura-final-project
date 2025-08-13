import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import { authService } from "./auth.service";
import type { ApiResponse } from "../types/common.types";
import type { UserManagementData, CursorPaginationResponse, UserStatusUpdateRequest } from "./admin.service";

export class ModerationService {
  
  // Check if current user has permission to perform user management actions
  hasUserManagementPermission(): boolean {
    const user = authService.getCurrentUser();
    return user && (user.roleName === "ADMIN" || user.roleName === "MODERATOR");
  }

  // Get current user role
  getCurrentUserRole(): string | null {
    const user = authService.getCurrentUser();
    return user?.roleName || null;
  }

  // Get users - Available for both ADMIN and MODERATOR
  async getUsers(params?: {
    cursor?: number;
    limit?: number;
    direction?: "NEXT" | "PREVIOUS";
  }): Promise<ApiResponse<CursorPaginationResponse<UserManagementData>>> {
    try {
      const queryParams = new URLSearchParams();
      if (params?.cursor) queryParams.append("cursor", params.cursor.toString());
      if (params?.limit) queryParams.append("limit", params.limit.toString());
      if (params?.direction) queryParams.append("direction", params.direction);

      const url = `${API_ENDPOINTS.ADMIN.USERS}${queryParams.toString() ? `?${queryParams.toString()}` : ""}`;
      return await apiClient.get<CursorPaginationResponse<UserManagementData>>(url);
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to fetch users",
      };
    }
  }

  // Search users - Available for both ADMIN and MODERATOR
  async searchUsers(searchTerm: string, params?: {
    cursor?: number;
    limit?: number;
    direction?: "NEXT" | "PREVIOUS";
  }): Promise<ApiResponse<CursorPaginationResponse<UserManagementData>>> {
    try {
      const queryParams = new URLSearchParams();
      queryParams.append("q", searchTerm);
      if (params?.cursor) queryParams.append("cursor", params.cursor.toString());
      if (params?.limit) queryParams.append("limit", params.limit.toString());
      if (params?.direction) queryParams.append("direction", params.direction);

      const url = `${API_ENDPOINTS.ADMIN.USER_SEARCH}?${queryParams.toString()}`;
      return await apiClient.get<CursorPaginationResponse<UserManagementData>>(url);
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to search users",
      };
    }
  }

  // Get user by ID - Available for both ADMIN and MODERATOR
  async getUserById(userId: string): Promise<ApiResponse<UserManagementData>> {
    try {
      const url = API_ENDPOINTS.ADMIN.USER_BY_ID(userId);
      return await apiClient.get<UserManagementData>(url);
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to fetch user details",
      };
    }
  }

  // Update user status - Only ADMIN can update user status
  async updateUserStatus(
    userId: string,
    request: UserStatusUpdateRequest
  ): Promise<ApiResponse<any>> {
    const userRole = this.getCurrentUserRole();
    
    if (userRole !== "ADMIN") {
      return {
        success: false,
        error: "Only administrators can update user status.",
      };
    }

    try {
      const url = API_ENDPOINTS.ADMIN.UPDATE_USER_STATUS(userId);
      return await apiClient.put<any>(url, request);
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to update user status",
      };
    }
  }

  // Check what actions are available for current user role
  getAvailableActions(): {
    canViewUsers: boolean;
    canViewUserDetails: boolean;
    canSuspendUsers: boolean;
    canRestoreUsers: boolean;
    canSetInactive: boolean;
  } {
    const userRole = this.getCurrentUserRole();
    
    if (userRole === "ADMIN") {
      return {
        canViewUsers: true,
        canViewUserDetails: true,
        canSuspendUsers: true,
        canRestoreUsers: true,
        canSetInactive: true,
      };
    }
    
    if (userRole === "MODERATOR") {
      return {
        canViewUsers: true,
        canViewUserDetails: true,
        canSuspendUsers: false,
        canRestoreUsers: false,
        canSetInactive: false,
      };
    }

    return {
      canViewUsers: false,
      canViewUserDetails: false,
      canSuspendUsers: false,
      canRestoreUsers: false,
      canSetInactive: false,
    };
  }
}

export const moderationService = new ModerationService();
