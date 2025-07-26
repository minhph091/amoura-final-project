import type { Metadata } from "next"
import { ReportManagement } from "@/components/reports/ReportManagement"

export const metadata: Metadata = {
  title: "Report Management | Amoura Admin",
  description: "Manage reported accounts for Amoura dating application",
}

export default function ReportsPage() {
  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="text-3xl font-bold tracking-tight">Report Management</h1>
      <ReportManagement />
    </div>
  )
}
