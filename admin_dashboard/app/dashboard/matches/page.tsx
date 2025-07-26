import type { Metadata } from "next"
import { MatchesList } from "@/components/matches/MatchesList"

export const metadata: Metadata = {
  title: "Matches | Amoura Admin",
  description: "Manage user matches for Amoura dating application",
}

export default function MatchesPage() {
  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="text-3xl font-bold tracking-tight">Match Management</h1>
      <MatchesList />
    </div>
  )
}
