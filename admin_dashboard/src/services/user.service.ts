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

const MOCK_USERS: User[] = [
  {
    id: 1,
    email: "sarah.j@example.com",
    firstName: "Sarah",
    lastName: "Johnson",
    fullName: "Sarah Johnson",
    username: "sarah_j",
    roleName: "USER",
    status: "ACTIVE",
    createdAt: "2023-05-12T10:00:00Z",
    lastLogin: "2024-06-29T08:00:00Z",
    avatar: "https://randomuser.me/api/portraits/women/12.jpg",
    initials: "SJ",
    joinDate: "May 12, 2023",
    location: "New York, USA",
    age: 28,
    gender: "FEMALE",
    lastActive: "2 hours ago",
    matches: 15,
    reports: 0,
    isVerified: true,
  },
  {
    id: 2,
    email: "alex.w@example.com",
    firstName: "Alex",
    lastName: "Wong",
    fullName: "Alex Wong",
    username: "alex_w",
    roleName: "USER",
    status: "ACTIVE",
    createdAt: "2023-05-11T10:00:00Z",
    lastLogin: "2024-06-29T03:00:00Z",
    avatar: "https://randomuser.me/api/portraits/men/22.jpg",
    initials: "AW",
    joinDate: "May 11, 2023",
    location: "Toronto, Canada",
    age: 32,
    gender: "MALE",
    lastActive: "5 hours ago",
    matches: 8,
    reports: 0,
    isVerified: false,
  },
  {
    id: 3,
    email: "maria.g@example.com",
    firstName: "Maria",
    lastName: "Garcia",
    fullName: "Maria Garcia",
    username: "maria_g",
    roleName: "USER",
    status: "PENDING",
    createdAt: "2023-05-10T10:00:00Z",
    lastLogin: "2024-06-28T10:00:00Z",
    avatar: "https://randomuser.me/api/portraits/women/28.jpg",
    initials: "MG",
    joinDate: "May 10, 2023",
    location: "Madrid, Spain",
    age: 26,
    gender: "FEMALE",
    lastActive: "1 day ago",
    matches: 3,
    reports: 0,
    isVerified: false,
  },
  {
    id: 4,
    email: "james.s@example.com",
    firstName: "James",
    lastName: "Smith",
    fullName: "James Smith",
    username: "james_s",
    roleName: "USER",
    status: "SUSPENDED",
    createdAt: "2023-05-09T10:00:00Z",
    lastLogin: "2024-06-26T10:00:00Z",
    avatar: "https://randomuser.me/api/portraits/men/32.jpg",
    initials: "JS",
    joinDate: "May 9, 2023",
    location: "London, UK",
    age: 35,
    gender: "MALE",
    lastActive: "3 days ago",
    matches: 12,
    reports: 2,
    isVerified: true,
  },
];

export class UserService {
  async getUsers(filters?: UserFilters): Promise<PaginatedResponse<User>> {
    // In development, return mock data
    if (process.env.NODE_ENV === "development") {
      await new Promise((resolve) => setTimeout(resolve, 500)); // Simulate API delay

      let filteredUsers = MOCK_USERS;

      if (filters?.search) {
        const search = filters.search.toLowerCase();
        filteredUsers = filteredUsers.filter(
          (user) =>
            user.fullName?.toLowerCase().includes(search) ||
            user.email.toLowerCase().includes(search) ||
            user.username?.toLowerCase().includes(search) ||
            user.id.toString().includes(search)
        );
      }

      if (filters?.status && filters.status !== "ALL") {
        filteredUsers = filteredUsers.filter(
          (user) => user.status === filters.status
        );
      }

      if (filters?.gender && filters.gender !== "ALL") {
        filteredUsers = filteredUsers.filter(
          (user) => user.gender === filters.gender
        );
      }

      // Sort
      if (filters?.sortBy) {
        filteredUsers.sort((a, b) => {
          const aValue = a[filters.sortBy as keyof User];
          const bValue = b[filters.sortBy as keyof User];
          const modifier = filters.sortOrder === "desc" ? -1 : 1;

          if (typeof aValue === "string" && typeof bValue === "string") {
            return aValue.localeCompare(bValue) * modifier;
          }

          if (typeof aValue === "number" && typeof bValue === "number") {
            return (aValue - bValue) * modifier;
          }

          return 0;
        });
      }

      const page = filters?.page || 1;
      const limit = filters?.limit || 10;
      const startIndex = (page - 1) * limit;
      const endIndex = startIndex + limit;

      return {
        success: true,
        data: filteredUsers.slice(startIndex, endIndex),
        pagination: {
          page,
          limit,
          total: filteredUsers.length,
          totalPages: Math.ceil(filteredUsers.length / limit),
          hasNext: endIndex < filteredUsers.length,
          hasPrev: page > 1,
        },
      };
    }

    // Production API call - Backend không có user list API cho admin
    // Sử dụng mock data vì backend chưa có admin endpoints
    return this.getUsers(filters); // Fallback to mock data
  }

  async getUser(id: string): Promise<ApiResponse<User>> {
    if (process.env.NODE_ENV === "development") {
      await new Promise((resolve) => setTimeout(resolve, 300));
      const user = MOCK_USERS.find((u) => u.id === parseInt(id));

      if (!user) {
        return { success: false, error: "User not found" };
      }

      return { success: true, data: user };
    }

    // Backend doesn't have this endpoint - fallback to mock
    return this.getUser(id);
  }

  async createUser(userData: CreateUserRequest): Promise<ApiResponse<User>> {
    // Backend doesn't have admin create user endpoint
    // This would need to use registration API but that's for regular users
    return {
      success: false,
      error: "Admin user creation not available in backend API",
    };
  }

  async updateUser(
    id: string,
    userData: UpdateUserRequest
  ): Promise<ApiResponse<User>> {
    // Backend only allows users to update their own profile
    return {
      success: false,
      error: "Admin user update not available in backend API",
    };
  }

  async deleteUser(id: string): Promise<ApiResponse<void>> {
    // Backend doesn't have user delete endpoint
    return {
      success: false,
      error: "User deletion not available in backend API",
    };
  }

  async suspendUser(id: string, reason?: string): Promise<ApiResponse<User>> {
    // Backend doesn't have user suspend endpoint
    return {
      success: false,
      error: "User suspension not available in backend API",
    };
  }

  async restoreUser(id: string): Promise<ApiResponse<User>> {
    // Backend doesn't have user restore endpoint
    return {
      success: false,
      error: "User restoration not available in backend API",
    };
  }

  async getUserStats(): Promise<ApiResponse<UserStats>> {
    if (process.env.NODE_ENV === "development") {
      await new Promise((resolve) => setTimeout(resolve, 300));

      const stats: UserStats = {
        totalUsers: MOCK_USERS.length,
        activeUsers: MOCK_USERS.filter((u) => u.status === "ACTIVE").length,
        suspendedUsers: MOCK_USERS.filter((u) => u.status === "SUSPENDED")
          .length,
        pendingUsers: MOCK_USERS.filter((u) => u.status === "PENDING").length,
        newUsersThisMonth: Math.floor(MOCK_USERS.length * 0.3),
        averageAge: Math.floor(
          MOCK_USERS.reduce((sum, u) => sum + (u.age || 0), 0) /
            MOCK_USERS.length
        ),
      };

      return { success: true, data: stats };
    }

    // Backend doesn't have user stats endpoint - use mock data
    return this.getUserStats();
  }
}

export const userService = new UserService();
