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
    try {
      return await apiClient.get<Notification[]>(
        API_ENDPOINTS.NOTIFICATIONS.UNREAD
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error
            ? error.message
            : "Failed to get unread notifications",
        data: [],
      };
    }
  }

  // Get unread count
  async getUnreadCount(): Promise<ApiResponse<number>> {
    try {
      return await apiClient.get<number>(
        API_ENDPOINTS.NOTIFICATIONS.UNREAD_COUNT
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to get unread count",
        data: 0,
      };
    }
  }

  // Mark notification as read
  async markAsRead(notificationId: string): Promise<ApiResponse<void>> {
    try {
      return await apiClient.put<void>(
        API_ENDPOINTS.NOTIFICATIONS.MARK_READ(notificationId)
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error
            ? error.message
            : "Failed to mark notification as read",
      };
    }
  }

  // Mark all notifications as read
  async markAllAsRead(): Promise<ApiResponse<void>> {
    try {
      return await apiClient.put<void>(
        API_ENDPOINTS.NOTIFICATIONS.MARK_ALL_READ
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error
            ? error.message
            : "Failed to mark all notifications as read",
      };
    }
  }

}

export const notificationService = new NotificationService();
