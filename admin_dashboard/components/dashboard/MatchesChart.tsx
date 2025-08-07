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
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from "recharts";

import { statsService } from "@/src/services/stats.service";

export function MatchesChart() {
  const { t } = useLanguage();
  const [data, setData] = useState<{ date: string; totalSwipes: number; totalMatches: number }[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchMatches = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await statsService.getDashboard();
        const backendData = response?.matchingSuccessChart;
        let chartData: { date: string; totalSwipes: number; totalMatches: number }[] = [];
        
        if (Array.isArray(backendData) && backendData.length > 0) {
          chartData = backendData
            .filter(item => item && item.date)
            .map((item: any) => ({
              date: item.date,
              totalSwipes: item.totalSwipes || 0,
              totalMatches: item.totalMatches || 0,
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
    fetchMatches();
  }, []);

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>{t.matchingSuccessRate}</CardTitle>
          <CardDescription>{t.totalSwipesVsMatches}</CardDescription>
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
          <CardTitle>{t.matchingSuccessRate}</CardTitle>
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
        <CardTitle>{t.matchingSuccessRate}</CardTitle>
        <CardDescription>
          {t.totalSwipesVsMatches}
        </CardDescription>
      </CardHeader>
      <CardContent className="h-80">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart
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
            <Bar
              dataKey="totalSwipes"
              fill="hsl(240, 10%, 70%)"
              radius={[4, 4, 0, 0]}
              name={t.totalSwipes}
            />
            <Bar
              dataKey="totalMatches"
              fill="hsl(346, 77%, 49%)"
              radius={[4, 4, 0, 0]}
              name={t.totalMatches}
            />
            <Legend />
          </BarChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}
