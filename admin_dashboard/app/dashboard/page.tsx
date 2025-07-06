import type { Metadata } from "next";
import { DashboardStats } from "@/components/dashboard/dashboard-stats";
import { UserGrowthChart } from "@/components/dashboard/user-growth-chart";
import { MatchesChart } from "@/components/dashboard/matches-chart";
import { RevenueChart } from "@/components/dashboard/revenue-chart";
import { RecentReportsWidget } from "@/components/dashboard/recent-reports-widget";
import { RecentUsers } from "@/components/dashboard/recent-users";

export const metadata: Metadata = {
  title: "Dashboard | Amoura Admin",
  description: "Admin dashboard for Amoura dating application",
};

export default function DashboardPage() {
  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="font-heading text-4xl font-bold text-gradient-primary tracking-tight mb-6">
        Dashboard Overview
      </h1>

      <DashboardStats />

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
        <UserGrowthChart />
        <MatchesChart />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mt-6">
        <div className="lg:col-span-1">
          <RevenueChart />
        </div>
        <div className="lg:col-span-2">
          <RecentReportsWidget />
        </div>
      </div>

      <div className="mt-6">
        <RecentUsers />
      </div>
    </div>
  );
}
