"use client";

import type { Metadata } from "next";
import { UserManagement } from "@/components/users/UserManagement";
import ErrorBoundary from "@/components/ErrorBoundary";
import { useLanguage } from "@/src/contexts/LanguageContext";

export default function UsersPage() {
  const { t } = useLanguage();

  return (
    <ErrorBoundary>
      <div className="space-y-6 animate-fade-in">
        <h1 className="font-heading text-4xl font-bold text-gradient-primary tracking-tight mb-6">
          {t.userManagement}
        </h1>
        <ErrorBoundary>
          <UserManagement />
        </ErrorBoundary>
      </div>
    </ErrorBoundary>
  );
}
