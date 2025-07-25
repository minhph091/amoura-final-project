import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type { ApiResponse, PaginatedResponse } from "../types/common.types";

export interface Report {
  id: number;
  reporterId: number;
  reportedUserId: number;
  type: string;
  reason: string;
  status: string;
  createdAt: string;
  resolvedAt?: string;
  resolvedBy?: number;
}

export interface ReportFilters {
  type?: string;
  status?: string;
  page?: number;
  limit?: number;
}

export class ReportService {
  async getReports(
    filters?: ReportFilters
  ): Promise<PaginatedResponse<Report>> {
    try {
      const params: Record<string, unknown> = {};
      if (filters?.type) params.type = filters.type;
      if (filters?.status) params.status = filters.status;
      if (filters?.page) params.page = filters.page;
      if (filters?.limit) params.limit = filters.limit;
      const response = await apiClient.get<Report[]>(
        API_ENDPOINTS.ADMIN.REPORTS,
        params
      );
      const page = filters?.page || 1;
      const limit = filters?.limit || 20;
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
        error: response.error || "Failed to fetch reports",
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
          error instanceof Error ? error.message : "Failed to fetch reports",
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

  async getReport(id: string): Promise<ApiResponse<Report>> {
    try {
      return await apiClient.get<Report>(
        `${API_ENDPOINTS.ADMIN.REPORTS}/${id}`
      );
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to get report",
      };
    }
  }

  async resolveReport(id: string): Promise<ApiResponse<void>> {
    try {
      return await apiClient.post<void>(
        `${API_ENDPOINTS.ADMIN.REPORTS}/${id}/resolve`
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to resolve report",
      };
    }
  }

  async rejectReport(id: string): Promise<ApiResponse<void>> {
    try {
      return await apiClient.post<void>(
        `${API_ENDPOINTS.ADMIN.REPORTS}/${id}/reject`
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to reject report",
      };
    }
  }
}

export const reportService = new ReportService();
