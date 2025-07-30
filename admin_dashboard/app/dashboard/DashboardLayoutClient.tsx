"use client";

import type React from "react";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { Sidebar } from "@/components/sidebar";
import { Header } from "@/components/header";
// Removed DashboardFooter import
import { ClientOnly } from "@/components/ClientOnly";
import { authService } from "@/src/services/auth.service";

export default function DashboardLayoutClient({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const router = useRouter();



  // Check if logged in - real backend validation
  useEffect(() => {
    // Chỉ kiểm tra token và role trong localStorage, không gọi API backend
    const token = typeof window !== "undefined" ? localStorage.getItem("auth_token") : null;
    const userDataRaw = typeof window !== "undefined" ? localStorage.getItem("user_data") : null;
    let roleName = undefined;
    if (userDataRaw) {
      try {
        const userObj = JSON.parse(userDataRaw);
        roleName = userObj.roleName;
      } catch {}
    }
    if (!token || !["ADMIN","MODERATOR"].includes(roleName)) {
      authService.logout();
      router.push("/login");
    }
  }, [router]);

  // Apply saved theme settings on page load
  useEffect(() => {
    // Only apply real user settings, no demo/mocked logic
    const savedColor = localStorage.getItem("primaryColor");
    const savedFontSize = localStorage.getItem("fontSize");
    const sidebarCollapsed = localStorage.getItem("sidebarCollapsed") === "true";

    // Set sidebar collapsed state on body (default: false)
    document.body.setAttribute(
      "data-sidebar-collapsed",
      String(!!sidebarCollapsed)
    );

    // Set primary color if present and valid
    if (savedColor && /^#[0-9A-Fa-f]{6}$/.test(savedColor)) {
      // Convert hex to hsl for CSS variables
      const r = Number.parseInt(savedColor.slice(1, 3), 16) / 255;
      const g = Number.parseInt(savedColor.slice(3, 5), 16) / 255;
      const b = Number.parseInt(savedColor.slice(5, 7), 16) / 255;

      const max = Math.max(r, g, b);
      const min = Math.min(r, g, b);
      let h: number = 0;
      let s: number = 0;
      let l: number = (max + min) / 2;

      if (max !== min) {
        const d = max - min;
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        switch (max) {
          case r:
            h = (g - b) / d + (g < b ? 6 : 0);
            break;
          case g:
            h = (b - r) / d + 2;
            break;
          case b:
            h = (r - g) / d + 4;
            break;
        }
        h /= 6;
      }

      h = Math.round((h ?? 0) * 360);
      s = Math.round((s ?? 0) * 100);
      l = Math.round((l ?? 0) * 100);

      document.documentElement.style.setProperty(
        "--primary",
        `${h} ${s}% ${l}%`
      );
    }

    // Set font size if present and valid
    if (savedFontSize && !isNaN(Number(savedFontSize))) {
      document.documentElement.style.fontSize = `${savedFontSize}px`;
    }
  }, []);

  return (
    <ClientOnly
      fallback={
        <div className="min-h-screen flex items-center justify-center">
          Loading...
        </div>
      }
    >
      <div
        className="flex min-h-screen flex-col bg-gradient-soft relative overflow-hidden"
        suppressHydrationWarning
      >
        {/* Subtle background elements for dashboard */}
        <div className="absolute top-0 right-0 w-96 h-96 bg-gradient-to-br from-pink-100/30 to-purple-100/30 rounded-full blur-3xl pointer-events-none"></div>
        <div className="absolute bottom-0 left-0 w-80 h-80 bg-gradient-to-tr from-rose-100/30 to-pink-100/30 rounded-full blur-3xl pointer-events-none"></div>

        <div className="flex flex-1 relative z-10" suppressHydrationWarning>
          <Sidebar />
          <div className="flex-1 main-content flex flex-col transition-all duration-300 ease-in-out">
            <Header />
            <main className="flex-1 p-6 pt-20 overflow-y-auto">{children}</main>
          </div>
        </div>
        {/* Footer is now handled globally in app/layout.tsx */}
      </div>
    </ClientOnly>
  );
}
