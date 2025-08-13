"use client";

import { formatNumber, calculateGrowthRate } from "@/src/utils/dashboard.utils";
import { useLanguage } from "@/src/contexts/LanguageContext";

import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useRouter } from "next/navigation";
import {
  Users,
  ShieldAlert,
  Flag,
  Heart,
  TrendingUp,
  ArrowRight,
} from "lucide-react";

type StatsCardProps = {
  title: string;
  value: string | number;
  description: string;
  icon: React.ReactNode;
  trend: number;
  href: string;
  color: string;
};

function StatsCard({
  title,
  value,
  description,
  icon,
  trend,
  href,
  color,
}: StatsCardProps) {
  const { t } = useLanguage();
  const router = useRouter();

  // Safe value formatting
  const displayValue = typeof value === 'number' ? formatNumber(value) : (value || '0');
  const displayTrend = typeof trend === 'number' ? trend : 0;

  return (
    <Card className="card-hover overflow-hidden border-none shadow-lg">
      <div className={`h-1 ${color}`}></div>
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <CardTitle className="text-sm font-medium font-primary">
          {title}
        </CardTitle>
        <div className={`p-2 ${color} bg-opacity-20 rounded-full`}>{icon}</div>
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold font-heading">{displayValue}</div>
        <p className="text-xs text-muted-foreground font-primary">
          {description}
        </p>
        <div className="flex items-center justify-between mt-4">
          <div className="flex items-center">
            <TrendingUp
              className={`h-4 w-4 ${
                displayTrend > 0 ? "text-green-500" : "text-destructive"
              } mr-1`}
            />
            <span
              className={`text-xs ${
                displayTrend > 0 ? "text-green-500" : "text-destructive"
              }`}
            >
              {displayTrend}% {t.fromLastMonth}
            </span>
          </div>
          <Button
            className="text-xs text-white btn-view hover:opacity-90"
            onClick={() => router.push(href)}
          >
            {t.view} <ArrowRight className="ml-1 h-3 w-3" />
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

export function DashboardStats() {
  const { t } = useLanguage();
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  useEffect(() => {
    async function fetchStats() {
      setLoading(true);
      setError(null);
      try {
        const res = await (await import("@/src/services/stats.service")).statsService.getDashboard();
        setStats(res);
      } catch (err: any) {
        if (err.message.includes('Backend service unavailable') || 
            err.message.includes('Network connection failed')) {
          setError("Backend service unavailable");
        } else {
          setError(err.message || "Failed to load statistics");
        }
      } finally {
        setLoading(false);
      }
    }
    fetchStats();
  }, []);

  if (loading) return <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4"><div className="animate-pulse bg-gray-200 h-32 rounded"></div><div className="animate-pulse bg-gray-200 h-32 rounded"></div><div className="animate-pulse bg-gray-200 h-32 rounded"></div><div className="animate-pulse bg-gray-200 h-32 rounded"></div></div>;
  if (error) return <div className="bg-red-50 border border-red-200 text-red-700 p-4 rounded-lg">⚠️ {error}</div>;
  if (!stats) return <div className="bg-gray-50 border border-gray-200 text-gray-600 p-4 rounded-lg">📊 Đang chờ dữ liệu dashboard từ server...</div>;

  // Tính toán trend (tăng trưởng) dựa trên dữ liệu userGrowthChart và matchingSuccessChart
  let userGrowthPercent = 0;
  if (stats?.userGrowthChart && Array.isArray(stats.userGrowthChart) && stats.userGrowthChart.length > 1) {
    const recent = stats.userGrowthChart.slice(-7); // 7 ngày gần nhất
    const previous = stats.userGrowthChart.slice(-14, -7); // 7 ngày trước đó
    const recentSum = recent.reduce((sum: number, day: any) => sum + (day?.newUsers || 0), 0);
    const previousSum = previous.reduce((sum: number, day: any) => sum + (day?.newUsers || 0), 0);
    if (previousSum > 0) {
      userGrowthPercent = Math.round(((recentSum - previousSum) / previousSum) * 100);
    }
  }
  
  let matchGrowthPercent = 0;
  if (stats?.matchingSuccessChart && Array.isArray(stats.matchingSuccessChart) && stats.matchingSuccessChart.length > 1) {
    const recent = stats.matchingSuccessChart.slice(-7); // 7 ngày gần nhất
    const previous = stats.matchingSuccessChart.slice(-14, -7); // 7 ngày trước đó
    const recentSum = recent.reduce((sum: number, day: any) => sum + (day?.totalMatches || 0), 0);
    const previousSum = previous.reduce((sum: number, day: any) => sum + (day?.totalMatches || 0), 0);
    if (previousSum > 0) {
      matchGrowthPercent = Math.round(((recentSum - previousSum) / previousSum) * 100);
    }
  }

  // Tính tăng trưởng cho messages dựa trên so sánh hôm nay vs tổng
  let messageGrowthPercent = 0;
  if ((stats?.totalMessages || 0) > 0 && (stats?.todayMessages || 0) > 0) {
    const avgDaily = (stats.totalMessages - stats.todayMessages) / 30; // Ước tính TB 30 ngày trước
    if (avgDaily > 0) {
      messageGrowthPercent = Math.round(((stats.todayMessages - avgDaily) / avgDaily) * 100);
    }
  }

  const statCards = [
    {
      title: t.totalUsers,
      value: stats?.totalUsers || 0,
      description: t.totalUsersPlatform,
      icon: <Users className="h-4 w-4 text-primary" />,
      trend: userGrowthPercent,
      href: "/dashboard/users",
      color: "bg-blue-500",
    },
    {
      title: t.activeUsersToday,
      value: stats?.activeUsersToday || 0,
      description: t.activeUsersTodayDesc,
      icon: <TrendingUp className="h-4 w-4 text-primary" />,
      trend: 0,
      href: "/dashboard/users",
      color: "bg-green-500",
    },
    {
      title: t.totalMatches,
      value: stats?.totalMatches || 0,
      description: t.totalMatchesPlatform,
      icon: <Heart className="h-4 w-4 text-primary" />,
      trend: matchGrowthPercent,
      href: "/dashboard/matches",
      color: "bg-rose-500",
    },
    {
      title: t.totalMessages,
      value: stats?.totalMessages || 0,
      description: t.totalMessagesSent,
      icon: <Flag className="h-4 w-4 text-primary" />,
      trend: messageGrowthPercent,
      href: "/dashboard/messages",
      color: "bg-amber-500",
    },
  ];

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      {statCards.map((stat) => (
        <StatsCard key={stat.title} {...stat} />
      ))}
    </div>
  );
}
