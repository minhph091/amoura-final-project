import React from "react";
import { useLanguage } from "@/src/contexts/LanguageContext";

export default function RoleLabel({ role }: { role: string }) {
  const { t } = useLanguage();
  
  let bg = "bg-gray-400";
  if (role === "ADMIN") bg = "bg-red-600";
  else if (role === "MODERATOR") bg = "bg-blue-600";
  else if (role === "USER") bg = "bg-green-600";
  
  // Map role to translation key
  const getRoleText = (role: string) => {
    switch (role) {
      case "ADMIN":
        return t.admin;
      case "MODERATOR":
        return t.moderator || "MODERATOR";
      case "USER":
        return t.user || "USER";
      default:
        return role;
    }
  };
  
  return (
    <span className={`px-3 py-1 rounded-md text-white text-sm font-bold ${bg} self-start mt-1`}>
      {getRoleText(role)}
    </span>
  );
}
