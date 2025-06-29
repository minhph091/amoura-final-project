import type { Metadata } from "next"
import { MessagesList } from "@/components/messages/messages-list"

export const metadata: Metadata = {
  title: "Messages | Amoura Admin",
  description: "Monitor user messages for Amoura dating application",
}

export default function MessagesPage() {
  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="text-3xl font-bold tracking-tight">Message Monitoring</h1>
      <MessagesList />
    </div>
  )
}
