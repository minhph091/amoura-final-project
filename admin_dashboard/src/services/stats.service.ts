
import { apiClient } from "./api.service";
import type { ApiResponse } from "../types/common.types";

// Định nghĩa đúng kiểu dữ liệu trả về từ backend
export interface AdminDashboardDTO {
  totalUsers: number;
  totalMatches: number;
  totalMessages: number;
  todayUsers: number;
  todayMatches: number;
  todayMessages: number;
  activeUsersToday: number;
  userGrowthChart: Array<{
    date: string;
    newUsers: number;
    totalUsers: number;
  }>;
  matchingSuccessChart: Array<{
    date: string;
    totalSwipes: number;
    totalMatches: number;
    successRate: number;
  }>;
  recentActivities: Array<{
    activityType: string;
    description: string;
    timestamp: string;
    userId: number | null;
    username: string;
  }>;
}

export class StatsService {
  async getDashboard(): Promise<AdminDashboardDTO> {
    // Chỉ gọi API nếu user là ADMIN
    const user = JSON.parse(localStorage.getItem("user_data") || "null");
    if (!user || user.roleName !== "ADMIN") {
      throw new Error("Bạn không có quyền truy cập dashboard quản trị.");
    }
    // Gọi API và trả về object backend trực tiếp
    const res = await apiClient.get<AdminDashboardDTO>("/admin/dashboard");
    // Nếu backend trả về {success, data}, lấy data; nếu trả về object trực tiếp, trả về luôn
    if (res && typeof res === "object" && "data" in res && res.data) {
      return res.data;
    }
    return res as unknown as AdminDashboardDTO;
  }
}

export const statsService = new StatsService();
