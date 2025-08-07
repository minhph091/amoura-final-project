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

  // Get users - for now, use admin endpoints but provide clear error messages for moderators
  async getUsers(params?: {
    cursor?: number;
    limit?: number;
    direction?: "NEXT" | "PREVIOUS";
  }): Promise<ApiResponse<CursorPaginationResponse<UserManagementData>>> {
    if (!this.hasUserManagementPermission()) {
      return {
        success: false,
        error: "Access denied. Admin or Moderator privileges required.",
      };
    }

    try {
      const queryParams = new URLSearchParams();
      if (params?.cursor) queryParams.append("cursor", params.cursor.toString());
      if (params?.limit) queryParams.append("limit", params.limit.toString());
      if (params?.direction) queryParams.append("direction", params.direction);

      // Currently using admin endpoints for all users since moderation endpoints are not implemented in backend
      const url = `${API_ENDPOINTS.ADMIN.USERS}${queryParams.toString() ? `?${queryParams.toString()}` : ""}`;
      return await apiClient.get<CursorPaginationResponse<UserManagementData>>(url);
    } catch (error) {
      // Handle permission errors specifically for moderators
      if (error instanceof Error && error.message.includes("403")) {
        const userRole = this.getCurrentUserRole();
        if (userRole === "MODERATOR") {
          return {
            success: false,
            error: "Moderator access to user management is not yet available. The backend moderation endpoints are not implemented. Please contact your administrator.",
          };
        }
        return {
          success: false,
          error: "Your account does not have permission to view user list. Please contact administrator.",
        };
      }
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to fetch users",
      };
    }
  }

  // Search users - for now, use admin endpoints but provide clear error messages for moderators
  async searchUsers(searchTerm: string, params?: {
    cursor?: number;
    limit?: number;
    direction?: "NEXT" | "PREVIOUS";
  }): Promise<ApiResponse<CursorPaginationResponse<UserManagementData>>> {
    if (!this.hasUserManagementPermission()) {
      return {
        success: false,
        error: "Access denied. Admin or Moderator privileges required.",
      };
    }

    try {
      const queryParams = new URLSearchParams();
      queryParams.append("q", searchTerm);
      if (params?.cursor) queryParams.append("cursor", params.cursor.toString());
      if (params?.limit) queryParams.append("limit", params.limit.toString());
      if (params?.direction) queryParams.append("direction", params.direction);

      // Currently using admin endpoints for all users since moderation endpoints are not implemented in backend
      const url = `${API_ENDPOINTS.ADMIN.USER_SEARCH}?${queryParams.toString()}`;
      return await apiClient.get<CursorPaginationResponse<UserManagementData>>(url);
    } catch (error) {
      if (error instanceof Error && error.message.includes("403")) {
        const userRole = this.getCurrentUserRole();
        if (userRole === "MODERATOR") {
          return {
            success: false,
            error: "Moderator access to user search is not yet available. The backend moderation endpoints are not implemented. Please contact your administrator.",
          };
        }
        return {
          success: false,
          error: "Your account does not have permission to search users. Please contact administrator.",
        };
      }
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to search users",
      };
    }
  }

  // Get user by ID - for now, use admin endpoints but provide clear error messages for moderators
  async getUserById(userId: string): Promise<ApiResponse<UserManagementData>> {
    if (!this.hasUserManagementPermission()) {
      return {
        success: false,
        error: "Access denied. Admin or Moderator privileges required.",
      };
    }

    try {
      // Currently using admin endpoints for all users since moderation endpoints are not implemented in backend
      const url = API_ENDPOINTS.ADMIN.USER_BY_ID(userId);
      return await apiClient.get<UserManagementData>(url);
    } catch (error) {
      if (error instanceof Error && error.message.includes("403")) {
        const userRole = this.getCurrentUserRole();
        if (userRole === "MODERATOR") {
          return {
            success: false,
            error: "Moderator access to user details is not yet available. The backend moderation endpoints are not implemented. Please contact your administrator.",
          };
        }
        return {
          success: false,
          error: "Your account does not have permission to view user details. Please contact administrator.",
        };
      }
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to fetch user details",
      };
    }
  }

  // Update user status - check if moderator has permission
  async updateUserStatus(
    userId: string,
    request: UserStatusUpdateRequest
  ): Promise<ApiResponse<any>> {
    if (!this.hasUserManagementPermission()) {
      return {
        success: false,
        error: "Access denied. Admin or Moderator privileges required.",
      };
    }

    const userRole = this.getCurrentUserRole();
    
    // Moderators might have limited permissions compared to admin
    if (userRole === "MODERATOR") {
      // For now, allow moderators to suspend/restore users
      // In the future, you might want to add more restrictions
      if (request.status === "INACTIVE") {
        return {
          success: false,
          error: "Moderators cannot set users to INACTIVE status. Only suspend or restore is allowed.",
        };
      }
    }

    try {
      // Currently using admin endpoints for all users since moderation endpoints are not implemented in backend
      const url = API_ENDPOINTS.ADMIN.UPDATE_USER_STATUS(userId);
      return await apiClient.put<any>(url, request);
    } catch (error) {
      if (error instanceof Error && error.message.includes("403")) {
        const userRole = this.getCurrentUserRole();
        if (userRole === "MODERATOR") {
          return {
            success: false,
            error: "Moderator access to user status updates is not yet available. The backend moderation endpoints are not implemented. Please contact your administrator.",
          };
        }
        return {
          success: false,
          error: "Your account does not have permission to update user status. Please contact administrator.",
        };
      }
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
        canViewUsers: true, // May be limited by backend
        canViewUserDetails: true, // May be limited by backend
        canSuspendUsers: true, // May be limited by backend
        canRestoreUsers: true, // May be limited by backend
        canSetInactive: false, // Restricted for moderators
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
