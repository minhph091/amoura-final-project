
"use client";

import { DashboardOverview } from "@/components/dashboard/DashboardOverview";
import AddAccountForm from "@/components/admin/AddAccountForm";
import RoleLabel from "@/components/common/RoleLabel";
import ErrorBoundary from "@/components/common/ErrorBoundary";
import { useLanguage } from "@/src/contexts/LanguageContext";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { authService } from "@/src/services/auth.service";

export default function DashboardPage() {
  const { t } = useLanguage();
  const [role, setRole] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    try {
      const user = authService.getCurrentUser();
      const token = localStorage.getItem("auth_token");
      
      if (!user || !token) {
        localStorage.clear();
        router.replace("/login");
        setLoading(true);
        return;
      }
      
      const roleName = user.roleName || null;
      setRole(roleName);
      
      if (roleName !== "ADMIN" && roleName !== "MODERATOR") {
        setError("Bạn không có quyền truy cập trang quản trị");
        return;
      }
      
      if (roleName === "MODERATOR") {
        router.replace("/");
        return;
      }
      
      setError(null);
    } catch (err) {
      setError("Authentication error occurred");
      localStorage.clear();
      router.replace("/login");
    } finally {
      setLoading(false);
    }
  }, [router]);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh]">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mb-4"></div>
        <p className="text-muted-foreground">{t.loadingText}</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh]">
        <div className="text-center">
          <h2 className="text-xl font-semibold text-red-600 mb-2">{t.errorTitle}</h2>
          <p className="text-gray-600 mb-4">{error}</p>
          <button 
            onClick={() => router.replace("/login")}
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
          >
            Go to Login
          </button>
        </div>
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
    <ErrorBoundary>
      <div className="space-y-6 animate-fade-in">
        <div className="flex flex-row items-center gap-3 mb-6">
          <h1 className="font-heading text-4xl font-bold text-gradient-primary tracking-tight">
            {t.dashboardOverview}
          </h1>
          {role && (
            <div className="flex items-center">
              <RoleLabel role={role} />
            </div>
          )}
        </div>

        {/* Use the new comprehensive dashboard component */}
        <ErrorBoundary fallback={
          <div className="text-red-500 p-4 rounded bg-red-50">
            {t.dashboardComponentFailed}
          </div>
        }>
          <DashboardOverview />
        </ErrorBoundary>
      </div>
    </ErrorBoundary>
  );
}
