"use client";

import type { Metadata } from "next"
import ModeratorManagement from "@/components/moderators/ModeratorManagement"
import { useLanguage } from "@/src/contexts/LanguageContext"

export default function ModeratorsPage() {
  const { t } = useLanguage();

  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="font-heading text-4xl font-bold text-gradient-primary tracking-tight mb-6">
        {t.moderatorManagement}
      </h1>
      <ModeratorManagement />
    </div>
  )
}
