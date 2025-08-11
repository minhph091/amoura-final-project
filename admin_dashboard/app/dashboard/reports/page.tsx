"use client";

import type { Metadata } from "next"
import { ReportManagement } from "@/components/reports/ReportManagement"
import ErrorBoundary from "@/components/ErrorBoundary"
import { useLanguage } from "@/src/contexts/LanguageContext"

export default function ReportsPage() {
  const { t } = useLanguage();

  return (
    <ErrorBoundary>
      <div className="space-y-6 animate-fade-in">
        <h1 className="font-heading text-4xl font-bold text-gradient-primary tracking-tight mb-6">
          {t.reportManagement}
        </h1>
        <ErrorBoundary>
          <ReportManagement />
        </ErrorBoundary>
      </div>
    </ErrorBoundary>
  )
}
