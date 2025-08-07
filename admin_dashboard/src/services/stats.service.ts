
import { adminService } from "./admin.service";
import type { AdminDashboardData } from "./admin.service";

export class StatsService {
  async getDashboard(): Promise<AdminDashboardData> {
    const user = JSON.parse(localStorage.getItem("user_data") || "null");
    if (!user || user.roleName !== "ADMIN") {
      throw new Error("Bạn không có quyền truy cập dashboard quản trị.");
    }
    
    const response = await adminService.getDashboard();
    if (!response.success || !response.data) {
      throw new Error(response.error || "Failed to fetch dashboard data");
    }
    
    return response.data;
  }
}

export const statsService = new StatsService();
