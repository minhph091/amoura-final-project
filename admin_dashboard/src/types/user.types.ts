// Backend UserDTO structure
export interface User {
  id: number; // Backend sử dụng Long (number)
  username?: string;
  email: string;
  phoneNumber?: string;
  firstName?: string;
  lastName?: string;
  fullName?: string;
  roleName?: string; // ADMIN, MODERATOR, USER
  status: UserStatus;
  lastLogin?: string; // ISO date string
  createdAt: string; // ISO date string
  updatedAt?: string; // ISO date string

  // Admin dashboard specific fields (computed from other data)
  avatar?: string; // From profile
  initials?: string; // Computed from name
  joinDate?: string; // Formatted createdAt
  location?: string; // From profile
  age?: number; // From profile
  gender?: Gender; // From profile
  lastActive?: string; // Formatted lastLogin
  matches?: number; // From matching data
  reports?: number; // From reports data
  isVerified?: boolean; // From profile verification
  bio?: string; // From profile
}

export type UserStatus = "ACTIVE" | "SUSPENDED" | "PENDING" | "BLOCKED"; // Backend enum values
export type Gender = "MALE" | "FEMALE" | "OTHER" | "PREFER_NOT_TO_SAY"; // Backend enum values

export interface UserPreferences {
  ageRange: {
    min: number;
    max: number;
  };
  maxDistance: number;
  interestedIn: Gender[];
  showOnlineStatus: boolean;
}

export interface CreateUserRequest {
  username?: string;
  email: string;
  password: string;
  phoneNumber?: string;
  firstName?: string;
  lastName?: string;
}

export interface UpdateUserRequest {
  username?: string;
  firstName?: string;
  lastName?: string;
  phoneNumber?: string;
}

export interface UserFilters {
  search?: string;
  status?: UserStatus | "ALL";
  role?: string | "ALL"; // ADMIN, MODERATOR, USER
  gender?: Gender | "ALL";
  ageRange?: {
    min: number;
    max: number;
  };
  location?: string;
  sortBy?: "fullName" | "createdAt" | "lastLogin" | "email";
  sortOrder?: "asc" | "desc";
  page?: number;
  limit?: number;
}

export interface UserStats {
  totalUsers: number;
  activeUsers: number;
  suspendedUsers: number;
  pendingUsers: number;
  newUsersThisMonth: number;
  averageAge?: number; // Optional since may not be available from backend
}
