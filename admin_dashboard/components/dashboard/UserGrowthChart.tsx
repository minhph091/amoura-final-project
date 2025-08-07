"use client";

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { useLanguage } from "@/src/contexts/LanguageContext";
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
  date: string;
  newUsers: number;
}

export function UserGrowthChart() {
  const { t } = useLanguage();
  const [data, setData] = useState<UserGrowthData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchUserGrowth = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await statsService.getDashboard();
        const backendData = response?.userGrowthChart;
        let chartData: UserGrowthData[] = [];
        
        if (Array.isArray(backendData) && backendData.length > 0) {
          chartData = backendData
            .filter(item => item && item.date)
            .map((item: any) => ({
              date: item.date,
              newUsers: item.newUsers || 0,
            }));
        }
        
        setData(chartData);
      } catch (err: any) {
        setData([]);
        setError("Backend service unavailable");
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
          <CardTitle>{t.userGrowth}</CardTitle>
          <CardDescription>{t.newUsersPerDay}</CardDescription>
        </CardHeader>
        <CardContent className="h-80 flex items-center justify-center">
          {t.loadingText}
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>{t.userGrowth}</CardTitle>
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
        <CardTitle>{t.userGrowth}</CardTitle>
        <CardDescription>
          {t.newUsersPerDay}
        </CardDescription>
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
            <XAxis dataKey="date" />
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
              dataKey="newUsers"
              stroke="hsl(346, 77%, 49%)"
              fill="hsl(346, 77%, 49%, 0.2)"
              name={t.newUsers}
            />
            <Legend />
          </AreaChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}
