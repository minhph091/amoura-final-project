"use client";

import type React from "react";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { Sidebar } from "@/components/sidebar";
import { Header } from "@/components/header";
import { DashboardFooter } from "@/components/ui/DashboardFooter";

export default function DashboardLayoutClient({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const router = useRouter();

  // Check if logged in
  useEffect(() => {
    const isLoggedIn = localStorage.getItem("isLoggedIn") === "true";
    if (!isLoggedIn) {
      router.push("/login");
    }
  }, [router]);

  // Apply saved theme settings on page load
  useEffect(() => {
    const savedColor = localStorage.getItem("primaryColor");
    const savedFontSize = localStorage.getItem("fontSize");
    const savedTheme = localStorage.getItem("theme");
    const sidebarCollapsed =
      localStorage.getItem("sidebarCollapsed") === "true";

    // Set sidebar collapsed state on body
    document.body.setAttribute(
      "data-sidebar-collapsed",
      String(sidebarCollapsed)
    );

    if (savedColor) {
      // Convert hex to hsl for CSS variables
      const r = Number.parseInt(savedColor.slice(1, 3), 16) / 255;
      const g = Number.parseInt(savedColor.slice(3, 5), 16) / 255;
      const b = Number.parseInt(savedColor.slice(5, 7), 16) / 255;

      const max = Math.max(r, g, b);
      const min = Math.min(r, g, b);
      let h,
        s,
        l = (max + min) / 2;

      if (max === min) {
        h = s = 0; // achromatic
      } else {
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

      h = Math.round(h * 360);
      s = Math.round(s * 100);
      l = Math.round(l * 100);

      document.documentElement.style.setProperty(
        "--primary",
        `${h} ${s}% ${l}%`
      );
    }

    if (savedFontSize) {
      document.documentElement.style.fontSize = `${savedFontSize}px`;
    }
  }, []);

  return (
    <div className="flex min-h-screen flex-col bg-gradient-soft relative overflow-hidden">
      {/* Subtle background elements for dashboard */}
      <div className="absolute top-0 right-0 w-96 h-96 bg-gradient-to-br from-pink-100/30 to-purple-100/30 rounded-full blur-3xl pointer-events-none"></div>
      <div className="absolute bottom-0 left-0 w-80 h-80 bg-gradient-to-tr from-rose-100/30 to-pink-100/30 rounded-full blur-3xl pointer-events-none"></div>

      <div className="flex flex-1 relative z-10">
        <Sidebar />
        <div className="flex-1 main-content flex flex-col">
          <Header />
          <main className="flex-1 p-6">{children}</main>
          <DashboardFooter />
        </div>
      </div>
    </div>
  );
}
