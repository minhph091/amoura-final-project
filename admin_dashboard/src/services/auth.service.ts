import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type {
  LoginRequest,
  LoginResponse,
  ChangePasswordRequest,
} from "../types/auth.types";
import type { ApiResponse } from "../types/common.types";

export class AuthService {
  async login(credentials: LoginRequest): Promise<ApiResponse<LoginResponse>> {
    try {
      const response = await apiClient.post<LoginResponse>(
        API_ENDPOINTS.AUTH.LOGIN,
        credentials
      );

      if (response.success && response.data) {
        // Store tokens
        apiClient.setToken(response.data.accessToken);
        localStorage.setItem("refresh_token", response.data.refreshToken);
        localStorage.setItem("user_data", JSON.stringify(response.data.user));

        // Check if user is admin or moderator
        if (
          response.data.user.roleName === "ADMIN" ||
          response.data.user.roleName === "MODERATOR"
        ) {
          return response;
        } else {
          // Clear tokens if not admin/moderator
          this.logout();
          return {
            success: false,
            error: "Access denied. Admin or Moderator role required.",
          };
        }
      }

      return response;
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Login failed",
      };
    }
  }

  async refreshToken(): Promise<ApiResponse<LoginResponse>> {
    const refreshToken = localStorage.getItem("refresh_token");
    if (!refreshToken) {
      return { success: false, error: "No refresh token available" };
    }

    try {
      const response = await apiClient.post<LoginResponse>(
        API_ENDPOINTS.AUTH.REFRESH,
        refreshToken
      );

      if (response.success && response.data) {
        apiClient.setToken(response.data.accessToken);
        localStorage.setItem("refresh_token", response.data.refreshToken);
        localStorage.setItem("user_data", JSON.stringify(response.data.user));
      }

      return response;
    } catch (error) {
      this.logout();
      return {
        success: false,
        error: error instanceof Error ? error.message : "Token refresh failed",
      };
    }
  }

  async logout(): Promise<void> {
    const refreshToken = localStorage.getItem("refresh_token");

    if (refreshToken) {
      try {
        await apiClient.post(API_ENDPOINTS.AUTH.LOGOUT, refreshToken);
      } catch (error) {
        console.warn("Logout API call failed:", error);
      }
    }

    // Clear stored data
    apiClient.clearToken();
    localStorage.removeItem("user_data");
    localStorage.removeItem("isLoggedIn");
  }

  async changePassword(
    request: ChangePasswordRequest
  ): Promise<ApiResponse<void>> {
    return apiClient.post<void>(API_ENDPOINTS.AUTH.CHANGE_PASSWORD, request);
  }

  getCurrentUser() {
    const userData = localStorage.getItem("user_data");
    return userData ? JSON.parse(userData) : null;
  }

  isAuthenticated(): boolean {
    const token = localStorage.getItem("auth_token");
    const userData = localStorage.getItem("user_data");
    return !!(token && userData);
  }

  isAdminOrModerator(): boolean {
    const user = this.getCurrentUser();
    return user && (user.roleName === "ADMIN" || user.roleName === "MODERATOR");
  }
}

export const authService = new AuthService();
