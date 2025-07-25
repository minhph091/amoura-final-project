import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type {
  User,
  UserFilters,
  CreateUserRequest,
  UpdateUserRequest,
  UserStats,
  PaginatedResponse,
  ApiResponse,
} from "../types";

export class UserService {
  async getUsers(filters?: UserFilters): Promise<PaginatedResponse<User>> {
    try {
      const res = await apiClient.get(
        API_ENDPOINTS.ADMIN.USERS,
        filters as Record<string, unknown>
      );
      return res as PaginatedResponse<User>;
    } catch (error) {
      throw error;
    }
  }

  async getUser(id: string): Promise<ApiResponse<User>> {
    try {
      const res = await apiClient.get(`${API_ENDPOINTS.ADMIN.USERS}/${id}`);
      return res as ApiResponse<User>;
    } catch (error) {
      throw error;
    }
  }

  async createUser(userData: CreateUserRequest): Promise<ApiResponse<User>> {
    try {
      const res = await apiClient.post(API_ENDPOINTS.ADMIN.USERS, userData);
      return res as ApiResponse<User>;
    } catch (error) {
      throw error;
    }
  }

  async updateUser(
    id: string,
    userData: UpdateUserRequest
  ): Promise<ApiResponse<User>> {
    try {
      const res = await apiClient.patch(
        `${API_ENDPOINTS.ADMIN.USERS}/${id}`,
        userData
      );
      return res as ApiResponse<User>;
    } catch (error) {
      throw error;
    }
  }

  async deleteUser(id: string): Promise<ApiResponse<void>> {
    try {
      const res = await apiClient.delete(`${API_ENDPOINTS.ADMIN.USERS}/${id}`);
      return res as ApiResponse<void>;
    } catch (error) {
      throw error;
    }
  }

  async suspendUser(id: string, reason?: string): Promise<ApiResponse<User>> {
    try {
      const res = await apiClient.post(
        `${API_ENDPOINTS.ADMIN.USERS}/${id}/suspend`,
        { reason }
      );
      return res as ApiResponse<User>;
    } catch (error) {
      throw error;
    }
  }

  async restoreUser(id: string): Promise<ApiResponse<User>> {
    try {
      const res = await apiClient.post(
        `${API_ENDPOINTS.ADMIN.USERS}/${id}/restore`
      );
      return res as ApiResponse<User>;
    } catch (error) {
      throw error;
    }
  }

  async getUserStats(): Promise<ApiResponse<UserStats>> {
    try {
      const res = await apiClient.get(API_ENDPOINTS.ADMIN.STATS);
      return res as ApiResponse<UserStats>;
    } catch (error) {
      throw error;
    }
  }
}

export const userService = new UserService();
