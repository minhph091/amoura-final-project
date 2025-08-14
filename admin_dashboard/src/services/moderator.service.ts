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
      // Backend queries chỉ filter users với role = 'USER' trong /admin/users
      // Cần tạo query riêng cho MODERATOR users
      // Vì backend chưa implement endpoint riêng cho moderators, ta tạm sử dụng fallback
      
      const page = filters?.page || 1;
      const limit = filters?.limit || 20;
      
      // Temporarily return empty data với thông báo chức năng chưa sẵn sàng
      // vì backend cần thêm endpoint để lấy users với role MODERATOR
      return {
        success: true,
        data: [], // Backend chưa có endpoint để lấy MODERATOR users
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
        error: "Moderator management feature requires backend support for role filtering",
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
