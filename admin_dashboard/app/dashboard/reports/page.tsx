import type { Metadata } from "next"
import { ReportManagement } from "@/components/reports/ReportManagement"

export const metadata: Metadata = {
  title: "Report Management | Amoura Admin",
  description: "Manage reported accounts for Amoura dating application",
}

export default function ReportsPage() {
  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="font-heading text-3xl font-extrabold tracking-tight mb-8 bg-gradient-to-r from-pink-500 via-fuchsia-500 to-purple-500 text-transparent bg-clip-text drop-shadow-lg animate-gradient-x">
        Report Management
      </h1>
      <ReportManagement />
    </div>
  )
}
