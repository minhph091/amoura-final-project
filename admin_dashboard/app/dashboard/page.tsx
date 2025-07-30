
"use client";

import { DashboardStats } from "@/components/dashboard/DashboardStats";
import { UserGrowthChart } from "@/components/dashboard/UserGrowthChart";
import { MatchesChart } from "@/components/dashboard/MatchesChart";
import { RevenueChart } from "@/components/dashboard/RevenueChart";
import { RecentReportsWidget } from "@/components/dashboard/RecentReportsWidget";
import RecentUsers from "@/components/dashboard/RecentUsers";
import AddAccountForm from "@/components/admin/AddAccountForm";
import RoleLabel from "@/components/common/RoleLabel";


import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { authService } from "@/src/services/auth.service";

export default function DashboardPage() {
  const [role, setRole] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    const user = authService.getCurrentUser();
    if (!user) {
      // Nếu chưa đăng nhập, chuyển về trang login
      router.replace("/login");
      setLoading(true);
      return;
    }
    const roleName = user.roleName || null;
    setRole(roleName);
    if (roleName === "MODERATOR") {
      router.replace("/");
    }
    setLoading(false);
  }, [router]);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh]">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mb-4"></div>
        <p className="text-muted-foreground">Loading...</p>
      </div>
    );
  }

  if (role === "MODERATOR") {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh]">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mb-4"></div>
        <p className="text-muted-foreground">Redirecting...</p>
      </div>
    );
  }

  // Mặc định: ADMIN
  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex flex-row items-baseline gap-2 mb-2">
        <h1 className="font-heading text-4xl font-bold text-gradient-primary tracking-tight mb-6">
          Dashboard Overview
        </h1>
        {role && <span className="ml-2"><RoleLabel role={role} /></span>}
      </div>
      {/* AddAccountForm removed from dashboard. Now a separate page for admins. */}
      <DashboardStats />
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
        <UserGrowthChart />
        <MatchesChart />
      </div>
      <div className="mt-6">
        <RecentUsers />
      </div>
    </div>
  );
}
