import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type { ApiResponse, PaginatedResponse } from "../types/common.types";

export interface Moderator {
  id: number;
  name: string;
  email: string;
  role: string;
  status: string;
  createdAt: string;
  updatedAt?: string;
}

export interface ModeratorFilters {
  role?: string;
  status?: string;
  page?: number;
  limit?: number;
}

export class ModeratorService {
  async getModerators(
    filters?: ModeratorFilters
  ): Promise<PaginatedResponse<Moderator>> {
    try {
      // Lấy tất cả user, lọc role MODERATOR (vì backend không có endpoint riêng cho moderator)
      const userRes = await apiClient.get<Moderator[]>("/user/all");
      let data = userRes.data || [];
      // Lọc role MODERATOR
      data = data.filter((u: any) => u.roleName === "MODERATOR");
      // Áp dụng filter status nếu có
      if (filters?.status) {
        data = data.filter((u: any) => u.status === filters.status);
      }
      // Phân trang thủ công
      const page = filters?.page || 1;
      const limit = filters?.limit || 20;
      const total = data.length;
      const totalPages = Math.ceil(total / limit);
      const paged = data.slice((page - 1) * limit, page * limit);
      return {
        success: true,
        data: paged,
        pagination: {
          page,
          limit,
          total,
          totalPages,
          hasNext: page < totalPages,
          hasPrev: page > 1,
        },
      };
    } catch (error) {
      const page = filters?.page || 1;
      const limit = filters?.limit || 20;
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to fetch moderators",
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

  async getModerator(id: string): Promise<ApiResponse<Moderator>> {
    try {
      return await apiClient.get<Moderator>(
        `${API_ENDPOINTS.ADMIN.MODERATORS}/${id}`
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to get moderator",
      };
    }
  }

  async createModerator(
    data: Partial<Moderator>
  ): Promise<ApiResponse<Moderator>> {
    try {
      return await apiClient.post<Moderator>(
        API_ENDPOINTS.ADMIN.MODERATORS,
        data
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to create moderator",
      };
    }
  }

  async updateModerator(
    id: string,
    data: Partial<Moderator>
  ): Promise<ApiResponse<Moderator>> {
    try {
      return await apiClient.patch<Moderator>(
        `${API_ENDPOINTS.ADMIN.MODERATORS}/${id}`,
        data
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to update moderator",
      };
    }
  }

  async deleteModerator(id: string): Promise<ApiResponse<void>> {
    try {
      return await apiClient.delete<void>(
        `${API_ENDPOINTS.ADMIN.MODERATORS}/${id}`
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to delete moderator",
      };
    }
  }
}

export const moderatorService = new ModeratorService();
