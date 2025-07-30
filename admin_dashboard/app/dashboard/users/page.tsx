import type { Metadata } from "next";
import { UserManagement } from "@/components/users/UserManagement";

export const metadata: Metadata = {
  title: "User Management | Amoura Admin",
  description: "Manage user accounts for Amoura dating application",
};

export default function UsersPage() {
  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="font-heading text-3xl font-extrabold tracking-tight mb-8 bg-gradient-to-r from-pink-500 via-fuchsia-500 to-purple-500 text-transparent bg-clip-text drop-shadow-lg animate-gradient-x">
        User Management
      </h1>
      <UserManagement />
    </div>
  );
}
