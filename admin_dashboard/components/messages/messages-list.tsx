"use client"

import { useState, useEffect } from "react"
import { Card, CardContent } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Search, Filter, MoreHorizontal, Eye, AlertTriangle, CheckCircle, Clock } from "lucide-react"

interface Message {
  id: string
  sender: {
    id: string
    name: string
    avatar: string
    initials: string
  }
  recipient: {
    id: string
    name: string
    avatar: string
    initials: string
  }
  content: string
  timestamp: string
  status: "sent" | "delivered" | "read" | "flagged"
  flagReason?: string
}

// Generate sample message data
const messages: Message[] = [
  {
    id: "MSG-10001",
    sender: {
      id: "U-7823",
      name: "Sarah Johnson",
      avatar: "https://randomuser.me/api/portraits/women/12.jpg",
      initials: "SJ",
    },
    recipient: {
      id: "U-7824",
      name: "Alex Wong",
      avatar: "https://randomuser.me/api/portraits/men/22.jpg",
      initials: "AW",
    },
    content: "Hey, I really enjoyed our conversation yesterday! Would you like to meet for coffee sometime?",
    timestamp: "2 hours ago",
    status: "read",
  },
  {
    id: "MSG-10002",
    sender: {
      id: "U-7825",
      name: "Maria Garcia",
      avatar: "https://randomuser.me/api/portraits/women/28.jpg",
      initials: "MG",
    },
    recipient: {
      id: "U-7826",
      name: "James Smith",
      avatar: "https://randomuser.me/api/portraits/men/32.jpg",
      initials: "JS",
    },
    content: "I noticed we both like hiking. Have you been to any good trails recently?",
    timestamp: "5 hours ago",
    status: "delivered",
  },
  {
    id: "MSG-10003",
    sender: {
      id: "U-7827",
      name: "Aisha Patel",
      avatar: "https://randomuser.me/api/portraits/women/44.jpg",
      initials: "AP",
    },
    recipient: {
      id: "U-7828",
      name: "David Kim",
      avatar: "https://randomuser.me/api/portraits/men/45.jpg",
      initials: "DK",
    },
    content: "Hey, want to exchange phone numbers and continue our conversation there?",
    timestamp: "1 day ago",
    status: "flagged",
    flagReason: "Potential personal information exchange",
  },
  {
    id: "MSG-10004",
    sender: {
      id: "U-7829",
      name: "Emma Wilson",
      avatar: "https://randomuser.me/api/portraits/women/17.jpg",
      initials: "EW",
    },
    recipient: {
      id: "U-7830",
      name: "Carlos Rodriguez",
      avatar: "https://randomuser.me/api/portraits/men/67.jpg",
      initials: "CR",
    },
    content: "I'm not interested in continuing this conversation. Please stop messaging me.",
    timestamp: "2 days ago",
    status: "read",
  },
  {
    id: "MSG-10005",
    sender: {
      id: "U-7831",
      name: "Olivia Brown",
      avatar: "https://randomuser.me/api/portraits/women/65.jpg",
      initials: "OB",
    },
    recipient: {
      id: "U-7832",
      name: "William Johnson",
      avatar: "https://randomuser.me/api/portraits/men/75.jpg",
      initials: "WJ",
    },
    content: "I had a great time on our date last night! Looking forward to seeing you again soon.",
    timestamp: "30 minutes ago",
    status: "sent",
  },
]

export function MessagesList() {
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState("all")
  const [visibleMessages, setVisibleMessages] = useState<Message[]>([])

  useEffect(() => {
    // Simulate loading messages with a delay
    const timer = setTimeout(() => {
      setVisibleMessages(messages)
    }, 500)

    return () => clearTimeout(timer)
  }, [])

  const filteredMessages = visibleMessages.filter((message) => {
    const matchesSearch =
      message.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      message.sender.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      message.recipient.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      message.content.toLowerCase().includes(searchTerm.toLowerCase())

    const matchesStatus = statusFilter === "all" || message.status === statusFilter

    return matchesSearch && matchesStatus
  })

  return (
    <div className="space-y-6">
      <Card>
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row gap-4 mb-6">
            <div className="relative flex-1">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
              <Input
                type="search"
                placeholder="Search messages by content or user name..."
                className="pl-8"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
            <div className="flex gap-2">
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-[180px]">
                  <div className="flex items-center gap-2">
                    <Filter className="h-4 w-4" />
                    <SelectValue placeholder="Filter by status" />
                  </div>
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Messages</SelectItem>
                  <SelectItem value="sent">Sent</SelectItem>
                  <SelectItem value="delivered">Delivered</SelectItem>
                  <SelectItem value="read">Read</SelectItem>
                  <SelectItem value="flagged">Flagged</SelectItem>
                </SelectContent>
              </Select>
              <Button>Export</Button>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-3 px-4 font-bold text-base">Message ID</th>
                  <th className="text-left py-3 px-4 font-bold text-base">Sender</th>
                  <th className="text-left py-3 px-4 font-bold text-base">Recipient</th>
                  <th className="text-left py-3 px-4 font-bold text-base">Content</th>
                  <th className="text-left py-3 px-4 font-bold text-base">Status</th>
                  <th className="text-left py-3 px-4 font-bold text-base hidden md:table-cell">Time</th>
                  <th className="text-right py-3 px-4 font-bold text-base">Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredMessages.length > 0 ? (
                  filteredMessages.map((message) => (
                    <tr key={message.id} className="border-b animate-fade-in hover:bg-muted/30">
                      <td className="py-3 px-4 font-medium">{message.id}</td>
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2">
                          <Avatar>
                            <AvatarImage src={message.sender.avatar || "/placeholder.svg"} alt={message.sender.name} />
                            <AvatarFallback>{message.sender.initials}</AvatarFallback>
                          </Avatar>
                          <div className="text-sm font-medium">{message.sender.name}</div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2">
                          <Avatar>
                            <AvatarImage
                              src={message.recipient.avatar || "/placeholder.svg"}
                              alt={message.recipient.name}
                            />
                            <AvatarFallback>{message.recipient.initials}</AvatarFallback>
                          </Avatar>
                          <div className="text-sm font-medium">{message.recipient.name}</div>
                        </div>
                      </td>
                      <td className="py-3 px-4 max-w-[200px]">
                        <div className="truncate text-sm">{message.content}</div>
                      </td>
                      <td className="py-3 px-4">
                        <Badge
                          variant={message.status === "flagged" ? "destructive" : "outline"}
                          className={
                            message.status === "read"
                              ? "bg-green-500 text-white"
                              : message.status === "delivered"
                                ? "bg-blue-500 text-white"
                                : message.status === "sent"
                                  ? "bg-gray-500 text-white"
                                  : ""
                          }
                        >
                          {message.status.charAt(0).toUpperCase() + message.status.slice(1)}
                        </Badge>
                      </td>
                      <td className="py-3 px-4 hidden md:table-cell">
                        <div className="flex items-center gap-2">
                          <Clock className="h-4 w-4 text-muted-foreground" />
                          <span>{message.timestamp}</span>
                        </div>
                      </td>
                      <td className="py-3 px-4 text-right">
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" size="icon">
                              <MoreHorizontal className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuItem>
                              <Eye className="mr-2 h-4 w-4" />
                              View Full Message
                            </DropdownMenuItem>
                            <DropdownMenuItem>View Conversation</DropdownMenuItem>
                            {message.status !== "flagged" ? (
                              <DropdownMenuItem className="text-destructive">
                                <AlertTriangle className="mr-2 h-4 w-4" />
                                Flag Message
                              </DropdownMenuItem>
                            ) : (
                              <DropdownMenuItem className="text-green-500">
                                <CheckCircle className="mr-2 h-4 w-4" />
                                Clear Flag
                              </DropdownMenuItem>
                            )}
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={7} className="py-10 text-center text-muted-foreground">
                      {visibleMessages.length > 0 ? "No messages found matching your criteria." : "Loading messages..."}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
