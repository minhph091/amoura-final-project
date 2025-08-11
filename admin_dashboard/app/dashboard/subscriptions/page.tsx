"use client";

import type { Metadata } from "next"
import { SubscriptionsList } from "@/components/subscriptions/subscriptions-list"
import { useLanguage } from "@/src/contexts/LanguageContext"

export default function SubscriptionsPage() {
  const { t } = useLanguage();

  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="font-heading text-4xl font-bold text-gradient-primary tracking-tight mb-6">
        {t.subscriptionManagement}
      </h1>
      <SubscriptionsList />
    </div>
  )
}
