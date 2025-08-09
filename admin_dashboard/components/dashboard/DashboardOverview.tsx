"use client";

import React, { useEffect, useState } from "react";
import { useLanguage } from "@/src/contexts/LanguageContext";
import { statsService } from "@/src/services/stats.service";
import { DashboardStats } from "./DashboardStats";
import { UserGrowthChart } from "./UserGrowthChart";
import { MatchesChart } from "./MatchesChart";
import RecentUsers from "./RecentUsers";
import type { AdminDashboardData } from "@/src/services/admin.service";

export function DashboardOverview() {
  const { t } = useLanguage();
  const [dashboardData, setDashboardData] = useState<AdminDashboardData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDashboardData = async () => {
      setLoading(true);
      try {
        const data = await statsService.getDashboard();
        setDashboardData(data);
      } catch (error) {
        console.error("Dashboard fetch error:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
    
    // Auto-refresh every 5 minutes
    const interval = setInterval(fetchDashboardData, 5 * 60 * 1000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-center min-h-[60vh]">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mb-4"></div>
          <p className="ml-4 text-muted-foreground">{t.loadingText}...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Thông báo nếu backend chưa có admin endpoints */}
      {dashboardData?.recentActivities?.some(activity => 
        activity.description.includes('Admin module chưa được deploy')
      ) && (
        <div className="bg-amber-50 border border-amber-200 text-amber-800 px-4 py-3 rounded-lg">
          <div className="flex items-start">
            <div className="flex-shrink-0">
              <span className="text-lg">🚧</span>
            </div>
            <div className="ml-3">
              <h3 className="text-sm font-medium">Thông báo hệ thống</h3>
              <p className="mt-1 text-sm">
                Admin dashboard đang hiển thị ở chế độ demo. Production server chưa deploy đầy đủ admin module endpoints.
                <br />
                <strong>Login thành công</strong> nhưng các chức năng quản trị cần backend team deploy thêm AdminController.
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Dashboard Stats */}
      <DashboardStats />

      {/* Charts */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <UserGrowthChart />
        <MatchesChart />
      </div>

      {/* Recent Activities */}
      <div className="mt-6">
        <RecentUsers />
      </div>
    </div>
  );
}
