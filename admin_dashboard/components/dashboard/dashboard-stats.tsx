"use client";

import type React from "react";

import { useState } from "react";
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

interface StatsCardProps {
  title: string;
  value: string;
  description: string;
  icon: React.ReactNode;
  trend: number;
  href: string;
  color: string;
}

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
  const [stats] = useState([
    {
      title: "Total Users",
      value: "12,345",
      description: "Active users on the platform",
      icon: <Users className="h-4 w-4 text-primary" />,
      trend: 12,
      href: "/dashboard/users",
      color: "bg-blue-500",
    },
    {
      title: "Moderators",
      value: "24",
      description: "Active content moderators",
      icon: <ShieldAlert className="h-4 w-4 text-primary" />,
      trend: 5,
      href: "/dashboard/moderators",
      color: "bg-purple-500",
    },
    {
      title: "Reports",
      value: "142",
      description: "Pending reports to review",
      icon: <Flag className="h-4 w-4 text-primary" />,
      trend: -8,
      href: "/dashboard/reports",
      color: "bg-amber-500",
    },
    {
      title: "Matches",
      value: "3,721",
      description: "Matches made this month",
      icon: <Heart className="h-4 w-4 text-primary" />,
      trend: 24,
      href: "/dashboard/matches",
      color: "bg-rose-500",
    },
  ]);

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      {stats.map((stat) => (
        <StatsCard key={stat.title} {...stat} />
      ))}
    </div>
  );
}
