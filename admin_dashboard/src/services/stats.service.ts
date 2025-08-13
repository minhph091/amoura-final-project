
import { adminService } from "./admin.service";
import type { AdminDashboardData } from "./admin.service";

export class StatsService {
  async getDashboard(): Promise<AdminDashboardData> {
    const user = JSON.parse(localStorage.getItem("user_data") || "null");
    const token = localStorage.getItem("auth_token");
    
    if (!user || !token || user.roleName !== "ADMIN") {
      throw new Error("Access denied. Only ADMIN can view dashboard.");
    }
    
    const response = await adminService.getDashboard();
    
    if (!response.success || !response.data) {
      throw new Error(response.error || "Failed to fetch dashboard data");
    }
    
    return response.data;
  }
}

export const statsService = new StatsService();
