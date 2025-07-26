"use client";

import React from "react";

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
  const router = useRouter();

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
        <div className="text-2xl font-bold font-heading">{value}</div>
        <p className="text-xs text-muted-foreground font-primary">
          {description}
        </p>
        <div className="flex items-center justify-between mt-4">
          <div className="flex items-center">
            <TrendingUp
              className={`h-4 w-4 ${
                trend > 0 ? "text-green-500" : "text-destructive"
              } mr-1`}
            />
            <span
              className={`text-xs ${
                trend > 0 ? "text-green-500" : "text-destructive"
              }`}
            >
              {trend}% from last month
            </span>
          </div>
          <Button
            className="text-xs text-white btn-view hover:opacity-90"
            onClick={() => router.push(href)}
          >
            View <ArrowRight className="ml-1 h-3 w-3" />
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

export function DashboardStats() {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  useEffect(() => {
    async function fetchStats() {
      setLoading(true);
      setError(null);
      try {
        const res = await (await import("@/src/services/stats.service")).statsService.getDashboard();
        setStats(res); // res là object backend trả về trực tiếp
      } catch (err: any) {
        setError(err.message || "Unknown error");
      } finally {
        setLoading(false);
      }
    }
    fetchStats();
  }, []);

  if (loading) return <div>Loading stats...</div>;
  if (error) return <div className="text-red-500">{error}</div>;
  if (!stats) return <div>No stats found.</div>;

  // Tính toán trend (tăng trưởng) dựa trên dữ liệu userGrowthChart và matchingSuccessChart
  let userGrowthPercent = 0;
  if (stats.userGrowthChart && stats.userGrowthChart.length > 1) {
    const first = stats.userGrowthChart[0].totalUsers;
    const last = stats.userGrowthChart[stats.userGrowthChart.length - 1].totalUsers;
    if (first > 0) {
      userGrowthPercent = Math.round(((last - first) / first) * 100);
    }
  }
  let matchGrowthPercent = 0;
  if (stats.matchingSuccessChart && stats.matchingSuccessChart.length > 1) {
    const first = stats.matchingSuccessChart[0].totalMatches;
    const last = stats.matchingSuccessChart[stats.matchingSuccessChart.length - 1].totalMatches;
    if (first > 0) {
      matchGrowthPercent = Math.round(((last - first) / first) * 100);
    }
  }

  const statCards = [
    {
      title: "Total Users",
      value: stats.totalUsers,
      description: "Total users on the platform",
      icon: <Users className="h-4 w-4 text-primary" />,
      trend: userGrowthPercent,
      href: "/dashboard/users",
      color: "bg-blue-500",
    },
    {
      title: "Active Users Today",
      value: stats.activeUsersToday,
      description: "Users active today",
      icon: <TrendingUp className="h-4 w-4 text-primary" />,
      trend: 0,
      href: "/dashboard/users",
      color: "bg-green-500",
    },
    {
      title: "Total Matches",
      value: stats.totalMatches,
      description: "Total matches on the platform",
      icon: <Heart className="h-4 w-4 text-primary" />,
      trend: matchGrowthPercent,
      href: "/dashboard/matches",
      color: "bg-rose-500",
    },
    {
      title: "Total Messages",
      value: stats.totalMessages,
      description: "Total messages sent",
      icon: <Flag className="h-4 w-4 text-primary" />,
      trend: 0,
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
