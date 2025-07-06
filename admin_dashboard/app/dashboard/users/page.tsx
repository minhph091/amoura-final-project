import type { Metadata } from "next";
import { UserManagement } from "@/components/users/UserManagement";

export const metadata: Metadata = {
  title: "User Management | Amoura Admin",
  description: "Manage user accounts for Amoura dating application",
};

export default function UsersPage() {
  return (
    <div className="animate-fade-in">
      <UserManagement />
    </div>
  );
}
