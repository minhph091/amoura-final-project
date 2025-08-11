import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type { ApiResponse } from "../types/common.types";

// Định nghĩa types theo backend DTO
export interface AdminDashboardData {
  totalUsers: number;
  totalMatches: number;
  totalMessages: number;
  todayUsers: number;
  todayMatches: number;
  todayMessages: number;
  activeUsersToday: number;
  userGrowthChart: Array<{
    date: string;
    newUsers: number;
  }>;
  matchingSuccessChart: Array<{
    date: string;
    totalSwipes: number;
    totalMatches: number;
  }>;
  recentActivities: Array<{
    activityType: string;
    description: string;
    timestamp: string;
  }>;
}

export interface UserManagementData {
  id: number;
  username: string;
  email: string;
  phoneNumber: string;
  firstName: string;
  lastName: string;
  status: "ACTIVE" | "INACTIVE" | "SUSPEND";
  lastLogin: string;
  createdAt: string;
  hasProfile: boolean;
  photoCount: number;
  totalMatches: number;
  totalMessages: number;
}

export interface CursorPaginationResponse<T> {
  data: T[];
  nextCursor: number;
  previousCursor: number;
  hasNext: boolean;
  hasPrevious: boolean;
  count: number;
}

export interface UserStatusUpdateRequest {
  status: "ACTIVE" | "INACTIVE" | "SUSPEND";
  reason?: string;
  suspensionDays?: number;
}

export interface StatusUpdateResponse {
  userId: number;
  oldStatus: string;
  newStatus: string;
  reason?: string;
  suspensionDays?: number;
  message: string;
}

export class AdminService {
  async getDashboard(): Promise<ApiResponse<AdminDashboardData>> {
    try {
      // Backend trả về trực tiếp AdminDashboardDTO object, không có wrapper
      const response = await apiClient.get<AdminDashboardData>(API_ENDPOINTS.ADMIN.DASHBOARD);
      
      // apiClient đã bọc trong ApiResponse, lấy data ra
      if (!response.success || !response.data) {
        return {
          success: false,
          error: response.error || "Failed to fetch dashboard data",
        };
      }

      // Backend response structure: trực tiếp là AdminDashboardDTO object
      const rawData = response.data;

      const processedData: AdminDashboardData = {
        totalUsers: rawData.totalUsers || 0,
        totalMatches: rawData.totalMatches || 0,
        totalMessages: rawData.totalMessages || 0,
        todayUsers: rawData.todayUsers || 0,
        todayMatches: rawData.todayMatches || 0,
        todayMessages: rawData.todayMessages || 0,
        activeUsersToday: rawData.activeUsersToday || 0,
        
        userGrowthChart: Array.isArray(rawData.userGrowthChart) && rawData.userGrowthChart.length > 0
          ? rawData.userGrowthChart.filter((item: any) => item && item.date).map((item: any) => ({
              date: item.date,
              newUsers: item.newUsers || 0
            }))
          : [],
          
        matchingSuccessChart: Array.isArray(rawData.matchingSuccessChart) && rawData.matchingSuccessChart.length > 0
          ? rawData.matchingSuccessChart.filter((item: any) => item && item.date).map((item: any) => ({
              date: item.date,
              totalSwipes: item.totalSwipes || 0,
              totalMatches: item.totalMatches || 0
            }))
          : [],
          
        recentActivities: Array.isArray(rawData.recentActivities) && rawData.recentActivities.length > 0
          ? rawData.recentActivities.filter((item: any) => item && item.activityType).map((item: any) => ({
              activityType: item.activityType,
              description: item.description || 'No description',
              timestamp: item.timestamp || new Date().toISOString()
            }))
          : []
      };

      return {
        success: true,
        data: processedData
      };

    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to fetch dashboard data",
      };
    }
  }

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

  async getUserById(userId: string): Promise<ApiResponse<UserManagementData>> {
    try {
      return await apiClient.get<UserManagementData>(API_ENDPOINTS.ADMIN.USER_BY_ID(userId));
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to fetch user details",
      };
    }
  }

  async updateUserStatus(
    userId: string,
    request: UserStatusUpdateRequest
  ): Promise<ApiResponse<StatusUpdateResponse>> {
    try {
      return await apiClient.put<StatusUpdateResponse>(
        API_ENDPOINTS.ADMIN.UPDATE_USER_STATUS(userId),
        request
      );
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to update user status",
      };
    }
  }
}

export const adminService = new AdminService();
