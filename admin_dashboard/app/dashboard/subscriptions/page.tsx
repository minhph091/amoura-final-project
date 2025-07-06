import type { Metadata } from "next"
import { SubscriptionsList } from "@/components/subscriptions/subscriptions-list"

export const metadata: Metadata = {
  title: "Subscriptions | Amoura Admin",
  description: "Manage premium subscriptions for Amoura dating application",
}

export default function SubscriptionsPage() {
  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="text-3xl font-bold tracking-tight">Subscription Management</h1>
      <SubscriptionsList />
    </div>
  )
}
