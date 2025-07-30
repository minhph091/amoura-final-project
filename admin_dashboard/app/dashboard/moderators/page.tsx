import type { Metadata } from "next"
import ModeratorManagement from "@/components/moderators/ModeratorManagement"

export const metadata: Metadata = {
  title: "Moderator Management | Amoura Admin",
  description: "Manage moderator accounts for Amoura dating application",
}

export default function ModeratorsPage() {
  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="font-heading text-3xl font-extrabold tracking-tight mb-8 bg-gradient-to-r from-pink-500 via-fuchsia-500 to-purple-500 text-transparent bg-clip-text drop-shadow-lg animate-gradient-x">
        Moderator Management
      </h1>
      <ModeratorManagement />
    </div>
  )
}
