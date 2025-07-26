import type { Metadata } from "next"
import { ModeratorManagement } from "@/components/moderators/ModeratorManagement"

export const metadata: Metadata = {
  title: "Moderator Management | Amoura Admin",
  description: "Manage moderator accounts for Amoura dating application",
}

export default function ModeratorsPage() {
  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="text-3xl font-bold tracking-tight">Moderator Management</h1>
      <ModeratorManagement />
    </div>
  )
}
