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
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from "recharts";

import { statsService } from "@/src/services/stats.service";

interface UserGrowthData {
  month: string;
  users: number;
}

export function UserGrowthChart() {
  const [data, setData] = useState<UserGrowthData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchUserGrowth = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await statsService.getStats();
        if (!response.success)
          throw new Error(response.error || "Failed to fetch user growth data");
        // Transform backend stats to chart format if needed
        const backendData = response.data?.monthlyRegistrations;
        let chartData: UserGrowthData[] = [];
        if (Array.isArray(backendData)) {
          chartData = backendData.map((item: any) => ({
            month: item.month || item.date || "",
            users: item.users || item.count || 0,
          }));
        }
        setData(chartData);
      } catch (err: any) {
        setError(err.message || "Unknown error");
      } finally {
        setLoading(false);
      }
    };
    fetchUserGrowth();
  }, []);

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>User Growth</CardTitle>
          <CardDescription>Monthly user registrations</CardDescription>
        </CardHeader>
        <CardContent className="h-80 flex items-center justify-center">
          Loading user growth data...
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>User Growth</CardTitle>
        </CardHeader>
        <CardContent className="h-80 flex items-center justify-center text-red-500">
          Error: {error}
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="card-hover">
      <CardHeader>
        <CardTitle>User Growth</CardTitle>
        <CardDescription>Monthly user registrations</CardDescription>
      </CardHeader>
      <CardContent className="h-80">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart
            data={data}
            margin={{
              top: 10,
              right: 30,
              left: 0,
              bottom: 0,
            }}
          >
            <CartesianGrid strokeDasharray="3 3" opacity={0.2} />
            <XAxis dataKey="month" />
            <YAxis />
            <Tooltip
              contentStyle={{
                backgroundColor: "var(--background)",
                borderColor: "var(--border)",
                borderRadius: "var(--radius)",
                boxShadow: "0 4px 12px rgba(0, 0, 0, 0.1)",
              }}
              itemStyle={{ color: "var(--foreground)" }}
              labelStyle={{ color: "var(--foreground)", fontWeight: "bold" }}
            />
            <Area
              type="monotone"
              dataKey="users"
              stroke="hsl(346, 77%, 49%)"
              fill="hsl(346, 77%, 49%, 0.2)"
              name="Users"
            />
            <Legend />
          </AreaChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}
