"use client";

import type React from "react";
import { usePathname, useRouter } from "next/navigation";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { ScrollArea } from "@/components/ui/scroll-area";
import {
  LayoutDashboard,
  Users,
  ShieldAlert,
  Flag,
  Heart,
  Menu,
  X,
  Crown,
} from "lucide-react";
import { useState, useEffect } from "react";
import { authService } from "@/src/services/auth.service";
import { useMobile } from "@/hooks/use-mobile";
import { AmouraLogo } from "@/components/ui/AmouraLogo";
import { useLanguage } from "@/src/contexts/LanguageContext";

interface SidebarNavProps extends React.HTMLAttributes<HTMLElement> {
  items: {
    href: string;
    title: string;
    icon: React.ReactNode;
  }[];
  isCollapsed: boolean;
}

export function Sidebar() {
  const [isOpen, setIsOpen] = useState(false);
  const [isCollapsed, setIsCollapsed] = useState(false);
  const isMobile = useMobile();
  const pathname = usePathname();
  const router = useRouter();
  const { t } = useLanguage();

  // Load sidebar state from localStorage on component mount
  useEffect(() => {
    const savedState = localStorage.getItem("sidebarCollapsed");
    if (savedState !== null) {
      setIsCollapsed(savedState === "true");
    }
  }, []);

  // Save sidebar state to localStorage when it changes
  useEffect(() => {
    localStorage.setItem("sidebarCollapsed", isCollapsed.toString());

    // Update the data-collapsed attribute on the body element
    document.body.setAttribute(
      "data-sidebar-collapsed",
      isCollapsed.toString()
    );
  }, [isCollapsed]);

  const toggleSidebar = () => {
    setIsOpen(!isOpen);
  };

  const toggleCollapse = () => {
    setIsCollapsed(!isCollapsed);
  };

  const user = authService.getCurrentUser();
  const isAdmin = user?.roleName === "ADMIN";
  const isModerator = user?.roleName === "MODERATOR";
  const sidebarItems = [
    {
      href: "/dashboard",
      title: t.dashboard,
      icon: <LayoutDashboard className="h-5 w-5" />,
      visible: isAdmin,
    },
    {
      href: "/dashboard/users",
      title: t.users,
      icon: <Users className="h-5 w-5" />,
      visible: isAdmin || isModerator,
    },
    {
      href: "/dashboard/moderators",
      title: t.moderators,
      icon: <ShieldAlert className="h-5 w-5" />,
      visible: isAdmin,
    },
    {
      href: "/dashboard/reports",
      title: t.reports,
      icon: <Flag className="h-5 w-5" />,
      visible: isAdmin || isModerator,
    },
    {
      href: "/dashboard/matches",
      title: t.matches,
      icon: <Heart className="h-5 w-5" />,
      visible: isAdmin,
    },
    {
      href: "/dashboard/subscriptions",
      title: t.subscriptions,
      icon: <Crown className="h-5 w-5" />,
      visible: isAdmin,
    },
  ];

  return (
    <>
      {isMobile && (
        <Button
          variant="ghost"
          size="icon"
          className="fixed top-4 left-4 z-50"
          onClick={toggleSidebar}
        >
          {isOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </Button>
      )}

      <aside
        className={cn(
          "bg-background border-r border-border flex-col z-40 transition-all duration-300 ease-in-out fixed h-screen shadow-2xl",
          isMobile
            ? `inset-y-0 left-0 transform ${
                isOpen ? "translate-x-0" : "-translate-x-full"
              }`
            : isCollapsed
            ? "w-16"
            : "w-64"
        )}
        data-collapsed={isCollapsed}
      >
        <div className="p-4 flex items-center justify-center border-b border-border bg-background">
          {isCollapsed ? (
            <div className="relative">
              <Heart className="h-8 w-8 text-rose-500 fill-rose-500" />
              <div className="absolute -top-1 -right-1 w-3 h-3 bg-gradient-to-r from-pink-400 to-rose-400 rounded-full" />
            </div>
          ) : (
            <div className="flex items-center space-x-2">
              <AmouraLogo size="small" />
            </div>
          )}
        </div>

        <div className="flex-grow flex flex-col h-[calc(100vh-80px)] relative">
          <ScrollArea className="flex-1">
            <nav className="grid gap-1 px-3 py-4">
              {sidebarItems.filter((item) => item.visible).map((item) => (
                <button
                  key={item.href}
                  onClick={() => router.push(item.href)}
                  className={cn(
                    "sidebar-item group flex items-center gap-3 rounded-xl px-3 py-3 text-sm font-medium font-primary transition-all duration-200 relative overflow-hidden w-full text-left",
                    "hover:bg-primary/10 dark:hover:bg-primary/20 hover:text-primary dark:hover:text-primary",
                    pathname === item.href
                      ? "bg-primary/20 text-primary shadow-lg shadow-primary/20"
                      : "text-slate-700 dark:text-slate-300",
                    isCollapsed ? "justify-center px-2" : ""
                  )}
                >
                  {pathname === item.href && (
                    <div className="absolute left-0 top-0 w-1 h-full bg-primary rounded-r-full shadow-lg shadow-primary/50" />
                  )}
                  <div
                    className={cn(
                      "flex items-center justify-center transition-transform group-hover:scale-110",
                      pathname === item.href
                        ? "text-primary"
                        : "group-hover:text-primary"
                    )}
                  >
                    {item.icon}
                  </div>
                  {!isCollapsed && (
                    <span className="sidebar-text transition-all duration-200 group-hover:translate-x-1 group-hover:text-primary">
                      {item.title}
                    </span>
                  )}
                  {pathname === item.href && !isCollapsed && (
                    <div className="ml-auto w-2 h-2 bg-primary rounded-full animate-pulse" />
                  )}
                </button>
              ))}
            </nav>
          </ScrollArea>

          <div className="p-4 flex justify-center border-t border-border">
            <Button
              variant="ghost"
              size="icon"
              onClick={toggleCollapse}
              className="bg-primary/20 hover:bg-primary/30 text-primary rounded-xl h-12 w-12 flex items-center justify-center shadow-lg transition-all duration-300 hover:scale-105 border border-primary/30"
              title={isCollapsed ? "Expand sidebar" : "Collapse sidebar"}
            >
              <Menu className="h-5 w-5" />
            </Button>
          </div>
        </div>
      </aside>

      {isMobile && isOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-30"
          onClick={() => setIsOpen(false)}
        />
      )}
    </>
  );
}
