"use client";

import type { Metadata } from "next"
import { AdminProfile } from "@/components/profile/AdminProfile"
import { useLanguage } from "@/src/contexts/LanguageContext";

export default function ProfilePage() {
  const { t } = useLanguage();
  
  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex items-center space-x-4">
        <h1 className="text-4xl font-bold bg-gradient-to-r from-pink-500 via-purple-500 to-blue-500 bg-clip-text text-transparent">
          {t.myProfileTitle}
        </h1>
        <div className="h-8 w-1 bg-gradient-to-b from-pink-500 to-blue-500 rounded-full"></div>
      </div>
      <AdminProfile />
    </div>
  )
}
