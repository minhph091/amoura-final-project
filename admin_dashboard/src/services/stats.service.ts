
import { adminService } from "./admin.service";
import type { AdminDashboardData } from "./admin.service";

export class StatsService {
  async getDashboard(): Promise<AdminDashboardData> {
    const user = JSON.parse(localStorage.getItem("user_data") || "null");
    const token = localStorage.getItem("auth_token");
    
    if (!user || !token || user.roleName !== "ADMIN") {
      throw new Error("Bạn không có quyền truy cập dashboard quản trị.");
    }
    
    try {
      const response = await adminService.getDashboard();
      
      if (!response.success || !response.data) {
        // Nếu backend thiếu endpoint thì return fallback data thay vì throw error
        if (response.error && response.error.includes('Resource not found')) {
          return this.getFallbackData();
        }
        throw new Error(response.error || "Failed to fetch dashboard data");
      }
      
      return response.data;
    } catch (error) {
      // Bất kỳ lỗi nào liên quan đến backend không có endpoint
      if (error instanceof Error && (
        error.message.includes('Resource not found') ||
        error.message.includes('Backend service unavailable') ||
        error.message.includes('Network connection failed') ||
        error.message.includes('fetch')
      )) {
        return this.getFallbackData();
      }
      
      throw error;
    }
  }
  
  private getFallbackData(): AdminDashboardData {
    return {
      totalUsers: 0,
      totalMatches: 0,
      totalMessages: 0,
      todayUsers: 0,
      todayMatches: 0,
      todayMessages: 0,
      activeUsersToday: 0,
      userGrowthChart: [],
      matchingSuccessChart: [],
      recentActivities: [{
        activityType: "SYSTEM_INFO",
        description: "🚧 Admin module chưa được deploy trên production server. Login thành công nhưng dashboard endpoints chưa khả dụng.",
        timestamp: new Date().toISOString()
      }]
    };
  }
}

export const statsService = new StatsService();
