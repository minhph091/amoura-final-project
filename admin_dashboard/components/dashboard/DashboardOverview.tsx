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
