
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
  const router = useRouter();

  useEffect(() => {
    const user = authService.getCurrentUser();
    const roleName = user?.roleName || null;
    setRole(roleName);
    if (roleName === "MODERATOR") {
      router.replace("/"); // Chuyển về trang home
    }
  }, [router]);

  if (role === "MODERATOR") {
    // Trả về loading trong khi chuyển hướng
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
      <div className="flex items-center gap-4 mb-2">
        <h1 className="font-heading text-4xl font-bold text-gradient-primary tracking-tight mb-6">
          Dashboard Overview
        </h1>
        {role && <RoleLabel role={role} />}
      </div>
      {role === "ADMIN" && (
        <div className="mb-6">
          <h2 className="font-bold mb-2">Add Admin/Moderator Account</h2>
          <AddAccountForm />
        </div>
      )}
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
