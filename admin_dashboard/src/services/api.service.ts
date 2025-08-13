import type { ApiResponse, PaginatedResponse } from "../types/common.types";
import { API_CONFIG } from "../config/api.config";

export class ApiClient {
  private baseURL: string;
  private token: string | null = null;

  constructor(baseURL = API_CONFIG.BASE_URL) {
    this.baseURL = baseURL;
    this.token = this.getStoredToken();
  }

  private getStoredToken(): string | null {
    if (typeof window === "undefined") return null;
    return localStorage.getItem("auth_token");
  }

  setToken(token: string) {
    this.token = token;
    if (typeof window !== "undefined") {
      localStorage.setItem("auth_token", token);
    }
  }

  clearToken() {
    this.token = null;
    if (typeof window !== "undefined") {
      localStorage.removeItem("auth_token");
      localStorage.removeItem("refresh_token");
    }
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    const url = `${this.baseURL}${endpoint}`;

    const headers = {
      "Content-Type": "application/json",
      ...options.headers,
    } as Record<string, string>;

    const currentToken = this.getStoredToken();
    if (currentToken) {
      this.token = currentToken;
      headers.Authorization = `Bearer ${this.token}`;
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers,
        credentials: 'include',
        mode: 'cors',
      });

      let data: any = null;
      const contentType = response.headers.get("content-type");
      const isJson = contentType && contentType.includes("application/json");
      const isNoContent = response.status === 204;
      
      if (!isNoContent && isJson) {
        try {
          data = await response.json();
        } catch (err) {
          return {
            success: false,
            error: "Invalid JSON response from server.",
          };
        }
      }

      if (!response.ok) {
        if (response.status === 404) {
          return {
            success: false,
            error: `Resource not found: ${endpoint}`,
          };
        }
        
        if (response.status === 403) {
          return {
            success: false,
            error: data?.message || "Access forbidden. Please check your permissions.",
          };
        }
        
        if (response.status === 401) {
          this.clearToken();
          // Nếu là lỗi 401, có thể token đã hết hạn
          if (typeof window !== "undefined") {
            localStorage.removeItem("isLoggedIn");
            // Trigger logout event for other components to listen
            window.dispatchEvent(new CustomEvent('token-expired'));
          }
          return {
            success: false,
            error: data?.message || "Authentication required. Please login again.",
          };
        }

        if (response.status === 0 || response.status >= 500) {
          return {
            success: false,
            error: "Backend service unavailable",
          };
        }
        
        return {
          success: false,
          error: (data && (data.message || data.error)) || `HTTP Error: ${response.status}`,
        };
      }

      if (data && data.accessToken && data.user) {
        return {
          success: true,
          data: data,
        };
      }

      return {
        success: true,
        data: data,
        message: data && data.message,
      };
    } catch (error) {
      if (error instanceof TypeError && error.message.includes('fetch')) {
        return {
          success: false,
          error: "Network connection failed",
        };
      }
      
      return {
        success: false,
        error: error instanceof Error ? error.message : "Network error",
      };
    }
  }

  async get<T>(
    endpoint: string,
    params?: Record<string, unknown>
  ): Promise<ApiResponse<T>> {
    const searchParams = params
      ? new URLSearchParams(params as Record<string, string>)
      : "";
    const url = searchParams ? `${endpoint}?${searchParams}` : endpoint;
    return this.request<T>(url);
  }

  async post<T>(endpoint: string, data?: unknown): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, {
      method: "POST",
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  async put<T>(endpoint: string, data?: unknown): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, {
      method: "PUT",
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  async patch<T>(endpoint: string, data?: unknown): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, {
      method: "PATCH",
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  async delete<T>(endpoint: string): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, {
      method: "DELETE",
    });
  }

  async getPaginated<T>(
    endpoint: string,
    params?: Record<string, unknown>
  ): Promise<PaginatedResponse<T>> {
    return this.get<T[]>(endpoint, params) as Promise<PaginatedResponse<T>>;
  }
}

export const apiClient = new ApiClient();
