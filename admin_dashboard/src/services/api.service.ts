import type { ApiResponse, PaginatedResponse } from "../types/common.types";
import { API_CONFIG } from "../config/api.config";

export class ApiClient {
  private baseURL: string;
  private token: string | null = null;

  constructor(
    baseURL = API_CONFIG.BASE_URL // Backend server URL
  ) {
    this.baseURL = baseURL;
    this.token = this.getStoredToken();
  }

  private getStoredToken(): string | null {
    if (typeof window === "undefined") return null;
    // Try different token storage keys
    return localStorage.getItem("access_token") || 
           localStorage.getItem("auth_token") || 
           localStorage.getItem("token");
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

    // Ensure fresh token for each request
    const currentToken = this.getStoredToken();
    if (currentToken) {
      this.token = currentToken;
      headers.Authorization = `Bearer ${this.token}`;
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers,
        // Remove credentials for proxy compatibility
        // credentials: 'include',
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
        // Handle 404 errors more gracefully
        if (response.status === 404) {
          return {
            success: false,
            error: `Resource not found: ${endpoint}`,
          };
        }
        
        // Handle 403 errors with more specific messages
        if (response.status === 403) {
          return {
            success: false,
            error: data?.message || "Access forbidden. Please check your permissions.",
          };
        }
        
        return {
          success: false,
          error: (data && data.message) || `HTTP Error: ${response.status}`,
        };
      }

      // Backend trả về trực tiếp DTO object, không wrap trong data field
      // Trừ login response có accessToken và user
      if (data && data.accessToken && data.user) {
        return {
          success: true,
          data: data,
        };
      }

      return {
        success: true,
        data: data, // Backend trả về trực tiếp AdminDashboardDTO, không cần .data
        message: data && data.message,
      };
    } catch (error) {
      // Network errors or connection issues
      if (error instanceof TypeError && error.message.includes('fetch')) {
        return {
          success: false,
          error: "Network connection failed. Please check your internet connection.",
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

  // Helper for paginated requests
  async getPaginated<T>(
    endpoint: string,
    params?: Record<string, unknown>
  ): Promise<PaginatedResponse<T>> {
    return this.get<T[]>(endpoint, params) as Promise<PaginatedResponse<T>>;
  }
}

export const apiClient = new ApiClient();
