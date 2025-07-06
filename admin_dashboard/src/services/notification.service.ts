import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type { ApiResponse, PaginatedResponse } from "../types/common.types";

// Notification types based on backend NotificationDTO
export interface Notification {
  id: number;
  userId: number;
  title: string;
  content: string;
  type: NotificationType;
  isRead: boolean;
  createdAt: string;
  readAt?: string;
  data?: Record<string, unknown>; // Additional data for notification
}

export type NotificationType =
  | "MATCH"
  | "MESSAGE"
  | "LIKE"
  | "VIEW"
  | "SYSTEM"
  | "MODERATION";

export interface NotificationFilters {
  userId?: number;
  type?: NotificationType | "ALL";
  isRead?: boolean;
  page?: number;
  limit?: number;
  sortBy?: "createdAt" | "readAt";
  sortOrder?: "asc" | "desc";
}

export interface NotificationStats {
  totalNotifications: number;
  unreadNotifications: number;
  readNotifications: number;
  todayNotifications: number;
  byType: Record<NotificationType, number>;
}

export class NotificationService {
  // Get all notifications (for admin monitoring)
  async getNotifications(
    filters?: NotificationFilters
  ): Promise<PaginatedResponse<Notification>> {
    try {
      const params: Record<string, unknown> = {};

      if (filters?.page) params.cursor = filters.page;
      if (filters?.limit) params.limit = filters.limit;
      if (filters?.sortOrder)
        params.direction = filters.sortOrder === "desc" ? "PREV" : "NEXT";

      const response = await apiClient.get<{
        notifications: Notification[];
        hasNext: boolean;
        nextCursor?: number;
      }>(API_ENDPOINTS.NOTIFICATIONS.LIST, params);

      if (response.success && response.data) {
        return {
          success: true,
          data: response.data.notifications || [],
          pagination: {
            page: filters?.page || 1,
            limit: filters?.limit || 20,
            total: response.data.notifications?.length || 0,
            totalPages: response.data.hasNext
              ? (filters?.page || 1) + 1
              : filters?.page || 1,
            hasNext: response.data.hasNext || false,
            hasPrev: (filters?.page || 1) > 1,
          },
        };
      }

      return {
        success: false,
        error: response.error || "Failed to fetch notifications",
        data: [],
        pagination: {
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 0,
          hasNext: false,
          hasPrev: false,
        },
      };
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error
            ? error.message
            : "Failed to fetch notifications",
        data: [],
        pagination: {
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 0,
          hasNext: false,
          hasPrev: false,
        },
      };
    }
  }

  // Get unread notifications
  async getUnreadNotifications(): Promise<ApiResponse<Notification[]>> {
    return apiClient.get<Notification[]>(API_ENDPOINTS.NOTIFICATIONS.UNREAD);
  }

  // Get unread count
  async getUnreadCount(): Promise<ApiResponse<number>> {
    return apiClient.get<number>(API_ENDPOINTS.NOTIFICATIONS.UNREAD_COUNT);
  }

  // Mark notification as read
  async markAsRead(notificationId: string): Promise<ApiResponse<void>> {
    return apiClient.put<void>(
      API_ENDPOINTS.NOTIFICATIONS.MARK_READ(notificationId)
    );
  }

  // Mark all notifications as read
  async markAllAsRead(): Promise<ApiResponse<void>> {
    return apiClient.put<void>(API_ENDPOINTS.NOTIFICATIONS.MARK_ALL_READ);
  }

  // Get notification statistics (mock data since backend may not have this)
  async getNotificationStats(): Promise<ApiResponse<NotificationStats>> {
    try {
      // Try to get real data first
      const unreadResponse = await this.getUnreadCount();
      const unreadCount = unreadResponse.success ? unreadResponse.data || 0 : 0;

      // Mock data for other stats since backend doesn't have statistics endpoint
      const stats: NotificationStats = {
        totalNotifications: 5420,
        unreadNotifications: unreadCount,
        readNotifications: 5420 - unreadCount,
        todayNotifications: 89,
        byType: {
          MATCH: 1200,
          MESSAGE: 2300,
          LIKE: 1500,
          VIEW: 300,
          SYSTEM: 100,
          MODERATION: 20,
        },
      };

      return {
        success: true,
        data: stats,
      };
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error
            ? error.message
            : "Failed to fetch notification stats",
      };
    }
  }
}

export const notificationService = new NotificationService();
