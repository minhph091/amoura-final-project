"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { useEffect, useState } from "react"
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer, Legend } from "recharts"

// Updated data for subscription plans (only Free and Premium)
const generateData = () => {
  return [
    { name: "Free", value: 8500 + Math.floor(Math.random() * 1000), color: "#94a3b8" },
    { name: "Premium", value: 3500 + Math.floor(Math.random() * 800), color: "#e11d48" },
  ]
}

export function RevenueChart() {
  const [data, setData] = useState([])
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
    setData(generateData())
  }, [])

  if (!mounted) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Subscription Distribution</CardTitle>
          <CardDescription>Distribution of users by subscription plan</CardDescription>
        </CardHeader>
        <CardContent className="h-80 flex items-center justify-center">Loading...</CardContent>
      </Card>
    )
  }

  const formatNumber = (value) => {
    return value.toLocaleString()
  }

  const totalUsers = data.reduce((sum, item) => sum + item.value, 0)

  return (
    <Card className="card-hover h-full">
      <CardHeader>
        <CardTitle>Subscription Distribution</CardTitle>
        <CardDescription>Distribution of users by subscription plan</CardDescription>
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
              label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
            >
              {data.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={entry.color} />
              ))}
            </Pie>
            <Tooltip
              formatter={(value, name) => [
                `${formatNumber(value)} users (${((value / totalUsers) * 100).toFixed(1)}%)`,
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
              formatter={(value, entry) => <span style={{ color: "var(--foreground)" }}>{value}</span>}
              layout="horizontal"
              verticalAlign="bottom"
              align="center"
            />
          </PieChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  )
}
