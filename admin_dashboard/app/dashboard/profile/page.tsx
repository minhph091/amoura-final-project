import type { Metadata } from "next"
import { AdminProfile } from "@/components/profile/admin-profile"

export const metadata: Metadata = {
  title: "Admin Profile | Amoura Admin",
  description: "Admin profile for Amoura dating application",
}

export default function ProfilePage() {
  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="text-3xl font-bold tracking-tight">My Profile</h1>
      <AdminProfile />
    </div>
  )
}
