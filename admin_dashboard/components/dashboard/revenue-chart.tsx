"use client";

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { useEffect, useState } from "react";
import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from "recharts";

import { subscriptionService } from "@/src/services/subscription.service";

export function RevenueChart() {
  type SubscriptionPlan = {
    name: string;
    value: number;
    color: string;
  };
  const [data, setData] = useState<SubscriptionPlan[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchRevenueData = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await subscriptionService.getSubscriptions({
          page: 1,
          limit: 100,
        });
        if (!response.success)
          throw new Error(
            response.error || "Failed to fetch subscription data"
          );
        // Transform backend data to chart format if needed
        const plans = (response.data ?? []).reduce((acc: any, sub: any) => {
          const plan = acc.find((p: any) => p.name === sub.plan);
          if (plan) {
            plan.value += 1;
          } else {
            acc.push({
              name: sub.plan,
              value: 1,
              color: sub.plan === "Premium" ? "#e11d48" : "#94a3b8",
            });
          }
          return acc;
        }, []);
        setData(plans);
      } catch (err: any) {
        setError(err.message || "Unknown error");
      } finally {
        setLoading(false);
      }
    };
    fetchRevenueData();
  }, []);

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Subscription Distribution</CardTitle>
          <CardDescription>
            Distribution of users by subscription plan
          </CardDescription>
        </CardHeader>
        <CardContent className="h-80 flex items-center justify-center">
          Loading...
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Subscription Distribution</CardTitle>
        </CardHeader>
        <CardContent className="h-80 flex items-center justify-center text-red-500">
          Error: {error}
        </CardContent>
      </Card>
    );
  }

  const formatNumber = (value: number) => {
    return value.toLocaleString();
  };

  const totalUsers = data.reduce((sum, item) => sum + (item.value || 0), 0);

  return (
    <Card className="card-hover h-full">
      <CardHeader>
        <CardTitle>Subscription Distribution</CardTitle>
        <CardDescription>
          Distribution of users by subscription plan
        </CardDescription>
      </CardHeader>
      <CardContent className="h-80">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={data}
              cx="50%"
              cy="50%"
              labelLine={false}
              outerRadius={80}
              fill="#8884d8"
              dataKey="value"
              label={({ name, percent }) =>
                `${name} ${percent ? (percent * 100).toFixed(0) : 0}%`
              }
            >
              {data.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={entry.color || "#8884d8"} />
              ))}
            </Pie>
            <Tooltip
              formatter={(value, name) => [
                `${formatNumber(value as number)} users (${(
                  ((value as number) / totalUsers) *
                  100
                ).toFixed(1)}%)`,
                name,
              ]}
              contentStyle={{
                backgroundColor: "var(--background)",
                borderColor: "var(--border)",
                borderRadius: "var(--radius)",
                boxShadow: "0 4px 12px rgba(0, 0, 0, 0.1)",
              }}
              itemStyle={{ color: "var(--foreground)" }}
              labelStyle={{ color: "var(--foreground)", fontWeight: "bold" }}
            />
            <Legend
              formatter={(value, entry) => (
                <span style={{ color: "var(--foreground)" }}>{value}</span>
              )}
              layout="horizontal"
              verticalAlign="bottom"
              align="center"
            />
          </PieChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}
