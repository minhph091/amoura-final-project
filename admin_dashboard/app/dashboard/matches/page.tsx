"use client";

import type { Metadata } from "next"
import { MatchesList } from "@/components/matches/MatchesList"
import ErrorBoundary from "@/components/ErrorBoundary"
import { useLanguage } from "@/src/contexts/LanguageContext"

export default function MatchesPage() {
  const { t } = useLanguage();

  return (
    <ErrorBoundary>
      <div className="space-y-6 animate-fade-in">
        <h1 className="font-heading text-4xl font-bold text-gradient-primary tracking-tight mb-6">
          {t.matchManagement}
        </h1>
        
        {/* Alert about matches feature */}
        <div className="bg-orange-50 border border-orange-200 rounded-lg p-4">
          <div className="flex items-center gap-3">
            <div className="w-3 h-3 bg-orange-500 rounded-full"></div>
            <div>
              <h4 className="font-medium text-orange-800">{t.matchManagement}</h4>
              <p className="text-sm text-orange-700">
                {t.featureComingSoon}
              </p>
            </div>
          </div>
        </div>

        <ErrorBoundary>
          <MatchesList />
        </ErrorBoundary>
      </div>
    </ErrorBoundary>
  )
}
