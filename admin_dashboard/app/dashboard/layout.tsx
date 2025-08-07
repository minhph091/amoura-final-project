import type { Metadata } from "next"
import type React from "react"
import DashboardLayoutClient from "./DashboardLayoutClient"

export const metadata: Metadata = {
  title: "Amoura Admin Dashboard",
  description: "Admin dashboard for Amoura dating platform",
}

interface DashboardLayoutProps {
  children: React.ReactNode
}

export default function DashboardLayout({ children }: DashboardLayoutProps) {
  return <DashboardLayoutClient>{children}</DashboardLayoutClient>
}
