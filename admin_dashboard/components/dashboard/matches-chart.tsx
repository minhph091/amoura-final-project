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

// Generate consistent data for days of the week
const generateData = () => {
  const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  // Use consistent data instead of random
  const matchesData = [26, 29, 18, 21, 19, 38, 32];

  return days.map((day, index) => ({
    day,
    matches: matchesData[index],
  }));
};

export function MatchesChart() {
  const [data, setData] = useState([]);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    setData(generateData());
  }, []);

  if (!mounted) {
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
