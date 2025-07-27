import React from "react";

export default function RoleLabel({ role }: { role: string }) {
  let bg = "bg-gray-400";
  if (role === "ADMIN") bg = "bg-red-600";
  else if (role === "MODERATOR") bg = "bg-blue-600";
  else if (role === "USER") bg = "bg-green-600";
  return (
    <span className={`px-2 py-1 rounded text-white text-xs font-bold ${bg}`}>
      {role}
    </span>
  );
}
