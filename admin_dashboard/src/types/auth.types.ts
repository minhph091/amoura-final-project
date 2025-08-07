import type { User } from "./user.types";

// Admin user sẽ là User với role ADMIN hoặc MODERATOR
export interface AdminUser extends User {
  permissions?: AdminPermission[];
}

export type AdminRole = "ADMIN" | "MODERATOR"; // Backend roles

export interface AdminPermission {
  id: string;
  name: string;
  description: string;
  resource: string;
  actions: AdminAction[];
}

export type AdminAction = "create" | "read" | "update" | "delete" | "manage";

// Backend LoginRequest structure
export interface LoginRequest {
  email?: string;
  phoneNumber?: string;
  password?: string;
  otpCode?: string;
  loginType: "EMAIL_PASSWORD" | "PHONE_PASSWORD" | "EMAIL_OTP";
}

// Backend AuthResponse structure
export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  user: User;
}

export interface AuthState {
  user: AdminUser | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
}

// Backend ChangePasswordRequest structure
export interface ChangePasswordRequest {
  currentPassword: string;
  newPassword: string;
}

// Forgot password types
export interface ForgotPasswordRequest {
  email: string;
}

export interface VerifyOtpRequest {
  sessionToken: string;
  otpCode: string;
}

export interface ResetPasswordRequest {
  sessionToken: string;
  newPassword: string;
}

export interface ForgotPasswordResponse {
  sessionToken: string;
  message: string;
}

export interface VerifyOtpResponse {
  status: string;
  message: string;
}

export interface ResetPasswordResponse {
  message: string;
}

export interface UpdateProfileRequest {
  firstName?: string;
  lastName?: string;
  username?: string;
  phoneNumber?: string;
}
