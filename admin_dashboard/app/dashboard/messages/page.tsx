import type { Metadata } from "next"
import { MessagesList } from "@/components/messages/MessagesList"
import ErrorBoundary from "@/components/ErrorBoundary"

export const metadata: Metadata = {
  title: "Messages | Amoura Admin",
  description: "Monitor user messages for Amoura dating application",
}

export default function MessagesPage() {
  return (
    <ErrorBoundary>
      <div className="space-y-6 animate-fade-in">
        <div className="flex items-center space-x-4">
          <h1 className="text-4xl font-bold bg-gradient-to-r from-blue-500 via-teal-500 to-green-500 bg-clip-text text-transparent">
            Message Monitoring
          </h1>
          <div className="h-8 w-1 bg-gradient-to-b from-blue-500 to-green-500 rounded-full"></div>
        </div>
        <ErrorBoundary>
          <MessagesList />
        </ErrorBoundary>
      </div>
    </ErrorBoundary>
  )
}
