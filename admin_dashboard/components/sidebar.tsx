"use client";

import type React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
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

  const sidebarItems = [
    {
      href: "/dashboard",
      title: t.dashboard,
      icon: <LayoutDashboard className="h-5 w-5" />,
    },
    {
      href: "/dashboard/users",
      title: t.users,
      icon: <Users className="h-5 w-5" />,
    },
    {
      href: "/dashboard/moderators",
      title: t.moderators,
      icon: <ShieldAlert className="h-5 w-5" />,
    },
    {
      href: "/dashboard/reports",
      title: t.reports,
      icon: <Flag className="h-5 w-5" />,
    },
    {
      href: "/dashboard/matches",
      title: t.matches,
      icon: <Heart className="h-5 w-5" />,
    },
    {
      href: "/dashboard/subscriptions",
      title: t.subscriptions,
      icon: <Crown className="h-5 w-5" />,
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
          "sidebar-glow border-r border-sidebar-border flex-col z-40 transition-all duration-300 ease-in-out fixed h-screen shadow-2xl backdrop-blur-sm",
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
        <div className="p-4 flex items-center justify-center border-b border-sidebar-border bg-sidebar/95 backdrop-blur-sm">
          {isCollapsed ? (
            <div className="h-8 w-8 bg-blue-500 rounded-lg flex items-center justify-center">
              <Heart className="h-5 w-5 text-white fill-white" />
            </div>
          ) : (
            <div className="flex items-center space-x-2">
              <div className="h-8 w-8 bg-blue-500 rounded-lg flex items-center justify-center">
                <Heart className="h-5 w-5 text-white fill-white" />
              </div>
              <span className="text-sidebar-foreground font-semibold text-lg">
                Amoura Admin
              </span>
            </div>
          )}
        </div>

        <div className="flex-grow flex flex-col h-[calc(100vh-80px)] relative">
          <ScrollArea className="flex-1">
            <nav className="grid gap-1 px-3 py-4">
              {sidebarItems.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className={cn(
                    "group flex items-center gap-3 rounded-xl px-3 py-3 text-sm font-medium font-primary transition-all duration-200 hover:bg-white/10 hover:text-white relative overflow-hidden",
                    pathname === item.href
                      ? "bg-blue-500/20 text-blue-300 shadow-lg shadow-blue-500/20"
                      : "text-sidebar-foreground/70 hover:text-sidebar-foreground",
                    isCollapsed ? "justify-center px-2" : ""
                  )}
                >
                  {pathname === item.href && (
                    <div className="absolute left-0 top-0 w-1 h-full bg-blue-400 rounded-r-full shadow-lg shadow-blue-400/50" />
                  )}
                  <div
                    className={cn(
                      "flex items-center justify-center transition-transform group-hover:scale-110",
                      pathname === item.href ? "text-blue-300" : ""
                    )}
                  >
                    {item.icon}
                  </div>
                  {!isCollapsed && (
                    <span className="transition-all duration-200 group-hover:translate-x-1">
                      {item.title}
                    </span>
                  )}
                  {pathname === item.href && !isCollapsed && (
                    <div className="ml-auto w-2 h-2 bg-blue-400 rounded-full animate-pulse-glow" />
                  )}
                </Link>
              ))}
            </nav>
          </ScrollArea>

          <div className="p-4 flex justify-center border-t border-sidebar-border">
            <Button
              variant="ghost"
              size="icon"
              onClick={toggleCollapse}
              className="bg-blue-500/20 hover:bg-blue-500/30 text-blue-300 hover:text-blue-200 rounded-xl h-12 w-12 flex items-center justify-center shadow-lg transition-all duration-300 hover:scale-105 border border-blue-500/30"
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
