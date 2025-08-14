import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type { ApiResponse, PaginatedResponse } from "../types/common.types";

export interface Subscription {
  id: number;
  userId: number;
  plan: string;
  status: string;
  startDate: string;
  endDate?: string;
  createdAt: string;
  updatedAt?: string;
}

export interface SubscriptionFilters {
  plan?: string;
  status?: string;
  page?: number;
  limit?: number;
}

export class SubscriptionService {
  async getSubscriptions(
    filters?: SubscriptionFilters
  ): Promise<PaginatedResponse<Subscription>> {
    try {
      const params: Record<string, unknown> = {};
      if (filters?.plan) params.plan = filters.plan;
      if (filters?.status) params.status = filters.status;
      const page = filters?.page || 1;
      const limit = filters?.limit || 20;
      if (filters?.page) params.page = filters.page;
      if (filters?.limit) params.limit = filters.limit;
      const response = await apiClient.get<Subscription[]>(
        API_ENDPOINTS.ADMIN.SUBSCRIPTIONS,
        params
      );
      const total = response.data ? response.data.length : 0;
      const totalPages = Math.ceil(total / limit);
      if (response.success && response.data) {
        return {
          success: true,
          data: response.data,
          pagination: {
            page,
            limit,
            total,
            totalPages,
            hasNext: page < totalPages,
            hasPrev: page > 1,
          },
        };
      }
      return {
        success: false,
        error: response.error || "Failed to fetch subscriptions",
        data: [],
        pagination: {
          page,
          limit,
          total: 0,
          totalPages: 0,
          hasNext: false,
          hasPrev: false,
        },
      };
    } catch (error) {
      const page = filters?.page || 1;
      const limit = filters?.limit || 20;
      return {
        success: false,
        error:
          error instanceof Error
            ? error.message
            : "Failed to fetch subscriptions",
        data: [],
        pagination: {
          page,
          limit,
          total: 0,
          totalPages: 0,
          hasNext: false,
          hasPrev: false,
        },
      };
    }
  }

  async getSubscription(id: string): Promise<ApiResponse<Subscription>> {
    try {
      return await apiClient.get<Subscription>(
        `${API_ENDPOINTS.ADMIN.SUBSCRIPTIONS}/${id}`
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to get subscription",
      };
    }
  }

  async createSubscription(
    data: Partial<Subscription>
  ): Promise<ApiResponse<Subscription>> {
    try {
      return await apiClient.post<Subscription>(
        API_ENDPOINTS.ADMIN.SUBSCRIPTIONS,
        data
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error
            ? error.message
            : "Failed to create subscription",
      };
    }
  }

  async updateSubscription(
    id: string,
    data: Partial<Subscription>
  ): Promise<ApiResponse<Subscription>> {
    try {
      return await apiClient.patch<Subscription>(
        `${API_ENDPOINTS.ADMIN.SUBSCRIPTIONS}/${id}`,
        data
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error
            ? error.message
            : "Failed to update subscription",
      };
    }
  }

  async cancelSubscription(id: string): Promise<ApiResponse<void>> {
    try {
      return await apiClient.post<void>(
        `${API_ENDPOINTS.ADMIN.SUBSCRIPTIONS}/${id}/cancel`
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error
            ? error.message
            : "Failed to cancel subscription",
      };
    }
  }
}

export const subscriptionService = new SubscriptionService();
