import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type {
  LoginRequest,
  LoginResponse,
  ChangePasswordRequest,
  ForgotPasswordRequest,
  VerifyOtpRequest,
  ResetPasswordRequest,
  ForgotPasswordResponse,
  VerifyOtpResponse,
  ResetPasswordResponse,
} from "../types/auth.types";
import type { ApiResponse } from "../types/common.types";

export class AuthService {

  async registerInitiate(data: any): Promise<ApiResponse<any>> {
    try {
      return await apiClient.post(API_ENDPOINTS.AUTH.REGISTER_INITIATE, data);
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : "Failed to register",
      };
    }
  }
  async login(credentials: LoginRequest): Promise<ApiResponse<LoginResponse>> {
    try {
      const response = await apiClient.post<LoginResponse>(
        API_ENDPOINTS.AUTH.LOGIN,
        credentials
      );

      if (response.success && response.data) {
        // Store tokens (always store accessToken as 'auth_token')
        apiClient.setToken(response.data.accessToken);
        localStorage.setItem("auth_token", response.data.accessToken);
        localStorage.setItem("refresh_token", response.data.refreshToken);
        localStorage.setItem("user_data", JSON.stringify(response.data.user));
        document.cookie = `auth_token=${response.data.accessToken}; path=/; max-age=86400`;

        // Check if user is admin or moderator
        if (
          response.data.user.roleName === "ADMIN" ||
          response.data.user.roleName === "MODERATOR"
        ) {
          localStorage.setItem("isLoggedIn", "true");
          return response;
        } else {
          // Clear tokens if not admin/moderator
          await this.logout();
          return {
            success: false,
            error: "Bạn không có quyền truy cập trang quản trị. Chỉ ADMIN hoặc MODERATOR mới được phép đăng nhập.",
          };
        }
      }

      // Nếu login thất bại, xóa sạch token, refresh_token, user_data
      this.clearAllAuthData();
      return response;
    } catch (error) {
      this.clearAllAuthData();
      return {
        success: false,
        error: error instanceof Error ? error.message : "Login failed",
      };
    }
  }

  clearAllAuthData() {
    apiClient.clearToken();
    localStorage.removeItem("auth_token");
    localStorage.removeItem("refresh_token");
    localStorage.removeItem("user_data");
    localStorage.removeItem("isLoggedIn");
    document.cookie = "auth_token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 UTC;";
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
        // Silent fail on logout API error
      }
    }
    this.clearAllAuthData();
    
    // Trigger storage event để notify các tabs khác
    if (typeof window !== "undefined") {
      window.dispatchEvent(new StorageEvent('storage', {
        key: 'auth_token',
        newValue: null,
        oldValue: localStorage.getItem('auth_token')
      }));
    }
  }

  async changePassword(
    request: ChangePasswordRequest
  ): Promise<ApiResponse<void>> {
    return apiClient.post<void>(API_ENDPOINTS.AUTH.CHANGE_PASSWORD, request);
  }

  // Forgot password methods
  async requestPasswordReset(request: ForgotPasswordRequest): Promise<ApiResponse<ForgotPasswordResponse>> {
    return apiClient.post<ForgotPasswordResponse>(API_ENDPOINTS.AUTH.PASSWORD_RESET_REQUEST, request);
  }

  async verifyPasswordResetOtp(request: VerifyOtpRequest): Promise<ApiResponse<VerifyOtpResponse>> {
    return apiClient.post<VerifyOtpResponse>(API_ENDPOINTS.AUTH.PASSWORD_RESET_VERIFY_OTP, request);
  }

  async resetPassword(request: ResetPasswordRequest): Promise<ApiResponse<ResetPasswordResponse>> {
    return apiClient.post<ResetPasswordResponse>(API_ENDPOINTS.AUTH.PASSWORD_RESET, request);
  }

  async resendPasswordResetOtp(sessionToken: string): Promise<ApiResponse<any>> {
    return apiClient.post<any>(API_ENDPOINTS.AUTH.PASSWORD_RESET_RESEND_OTP, { sessionToken });
  }

  getCurrentUser() {
    const userData = localStorage.getItem("user_data");
    return userData ? JSON.parse(userData) : null;
  }

  isAuthenticated(): boolean {
    const token = localStorage.getItem("auth_token");
    const userData = localStorage.getItem("user_data");
    return Boolean(token && userData);
  }

  isAdminOrModerator(): boolean {
    const user = this.getCurrentUser();
    return !!(user && (user.roleName === "ADMIN" || user.roleName === "MODERATOR"));
  }
}

export const authService = new AuthService();
