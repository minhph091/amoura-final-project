"use client";

import React, { useEffect } from "react";
import { useRouter } from "next/navigation";
import { authService } from "@/src/services/auth.service";

export default function AdminRootPage() {
  const router = useRouter();

  useEffect(() => {
    if (typeof window !== "undefined") {
      const user = authService.getCurrentUser();
      const role = user?.roleName;
      if (role === "ADMIN") {
        router.replace("/dashboard");
      } else if (role === "MODERATOR") {
        router.replace("/dashboard/users"); // hoặc /dashboard/reports tuỳ bạn muốn
      }
      // Nếu chưa login hoặc role khác thì giữ nguyên trang home
    }
  }, [router]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800 flex items-center justify-center">
      <div className="text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
        <p className="text-muted-foreground">
          Redirecting...
        </p>
      </div>
    </div>
  );
}
