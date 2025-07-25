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
  const [data, setData] = useState<{ day: string; matches: number }[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchMatches = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await statsService.getStats();
        if (!response.success || !response.data?.weeklyMatches)
          throw new Error(response.error || "Failed to fetch matches data");
        // Transform backend weeklyMatches to expected array
        const backendData = response.data.weeklyMatches;
        let chartData: { day: string; matches: number }[] = [];
        if (Array.isArray(backendData)) {
          chartData = backendData.map((item: any) => ({
            day: item.day || item.date || "",
            matches: item.matches || item.count || 0,
          }));
        }
        setData(chartData);
      } catch (err: any) {
        setError(err.message || "Unknown error");
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
          <CardTitle>Weekly Matches</CardTitle>
          <CardDescription>Successful matches by day of week</CardDescription>
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
          <CardTitle>Weekly Matches</CardTitle>
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
        <CardTitle>Weekly Matches</CardTitle>
        <CardDescription>Successful matches by day of week</CardDescription>
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
            <XAxis dataKey="day" />
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
              dataKey="matches"
              fill="hsl(346, 77%, 49%)"
              radius={[4, 4, 0, 0]}
              name="Matches"
            />
            <Legend />
          </BarChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
}
