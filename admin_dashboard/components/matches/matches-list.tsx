"use client"

import { useState, useEffect } from "react"
import { Card, CardContent } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Search, Filter, MoreHorizontal, Eye, Heart, Calendar, Clock } from "lucide-react"

interface Match {
  id: string
  user1: {
    id: string
    name: string
    avatar: string
    initials: string
  }
  user2: {
    id: string
    name: string
    avatar: string
    initials: string
  }
  status: "active" | "inactive" | "blocked"
  matchDate: string
  compatibility: number
  lastInteraction: string
  messageCount: number
}

// Generate sample match data
const matches: Match[] = [
  {
    id: "MATCH-1001",
    user1: {
      id: "U-7823",
      name: "Sarah Johnson",
      avatar: "https://randomuser.me/api/portraits/women/12.jpg",
      initials: "SJ",
    },
    user2: {
      id: "U-7824",
      name: "Alex Wong",
      avatar: "https://randomuser.me/api/portraits/men/22.jpg",
      initials: "AW",
    },
    status: "active",
    matchDate: "May 15, 2023",
    compatibility: 92,
    lastInteraction: "2 hours ago",
    messageCount: 156,
  },
  {
    id: "MATCH-1002",
    user1: {
      id: "U-7825",
      name: "Maria Garcia",
      avatar: "https://randomuser.me/api/portraits/women/28.jpg",
      initials: "MG",
    },
    user2: {
      id: "U-7826",
      name: "James Smith",
      avatar: "https://randomuser.me/api/portraits/men/32.jpg",
      initials: "JS",
    },
    status: "inactive",
    matchDate: "May 10, 2023",
    compatibility: 78,
    lastInteraction: "5 days ago",
    messageCount: 42,
  },
  {
    id: "MATCH-1003",
    user1: {
      id: "U-7827",
      name: "Aisha Patel",
      avatar: "https://randomuser.me/api/portraits/women/44.jpg",
      initials: "AP",
    },
    user2: {
      id: "U-7828",
      name: "David Kim",
      avatar: "https://randomuser.me/api/portraits/men/45.jpg",
      initials: "DK",
    },
    status: "active",
    matchDate: "May 12, 2023",
    compatibility: 85,
    lastInteraction: "1 day ago",
    messageCount: 89,
  },
  {
    id: "MATCH-1004",
    user1: {
      id: "U-7829",
      name: "Emma Wilson",
      avatar: "https://randomuser.me/api/portraits/women/17.jpg",
      initials: "EW",
    },
    user2: {
      id: "U-7830",
      name: "Carlos Rodriguez",
      avatar: "https://randomuser.me/api/portraits/men/67.jpg",
      initials: "CR",
    },
    status: "blocked",
    matchDate: "May 8, 2023",
    compatibility: 65,
    lastInteraction: "User blocked",
    messageCount: 23,
  },
  {
    id: "MATCH-1005",
    user1: {
      id: "U-7831",
      name: "Olivia Brown",
      avatar: "https://randomuser.me/api/portraits/women/65.jpg",
      initials: "OB",
    },
    user2: {
      id: "U-7832",
      name: "William Johnson",
      avatar: "https://randomuser.me/api/portraits/men/75.jpg",
      initials: "WJ",
    },
    status: "active",
    matchDate: "May 16, 2023",
    compatibility: 95,
    lastInteraction: "30 minutes ago",
    messageCount: 42,
  },
]

export function MatchesList() {
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState("all")
  const [visibleMatches, setVisibleMatches] = useState<Match[]>([])

  useEffect(() => {
    // Simulate loading matches with a delay
    const timer = setTimeout(() => {
      setVisibleMatches(matches)
    }, 500)

    return () => clearTimeout(timer)
  }, [])

  const filteredMatches = visibleMatches.filter((match) => {
    const matchesSearch =
      match.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      match.user1.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      match.user2.name.toLowerCase().includes(searchTerm.toLowerCase())

    const matchesStatus = statusFilter === "all" || match.status === statusFilter

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
                placeholder="Search matches by ID or user name..."
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
                  <SelectItem value="all">All Matches</SelectItem>
                  <SelectItem value="active">Active</SelectItem>
                  <SelectItem value="inactive">Inactive</SelectItem>
                  <SelectItem value="blocked">Blocked</SelectItem>
                </SelectContent>
              </Select>
              <Button>Export</Button>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-3 px-4 font-bold text-base">Match ID</th>
                  <th className="text-left py-3 px-4 font-bold text-base">Users</th>
                  <th className="text-left py-3 px-4 font-bold text-base">Status</th>
                  <th className="text-left py-3 px-4 font-bold text-base hidden md:table-cell">Match Date</th>
                  <th className="text-left py-3 px-4 font-bold text-base hidden lg:table-cell">Compatibility</th>
                  <th className="text-left py-3 px-4 font-bold text-base hidden lg:table-cell">Last Interaction</th>
                  <th className="text-right py-3 px-4 font-bold text-base">Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredMatches.length > 0 ? (
                  filteredMatches.map((match) => (
                    <tr key={match.id} className="border-b animate-fade-in hover:bg-muted/30">
                      <td className="py-3 px-4 font-medium">{match.id}</td>
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2">
                          <div className="flex -space-x-2">
                            <Avatar className="border-2 border-background">
                              <AvatarImage src={match.user1.avatar || "/placeholder.svg"} alt={match.user1.name} />
                              <AvatarFallback>{match.user1.initials}</AvatarFallback>
                            </Avatar>
                            <Avatar className="border-2 border-background">
                              <AvatarImage src={match.user2.avatar || "/placeholder.svg"} alt={match.user2.name} />
                              <AvatarFallback>{match.user2.initials}</AvatarFallback>
                            </Avatar>
                          </div>
                          <div className="ml-2">
                            <div className="text-sm font-medium">{match.user1.name}</div>
                            <div className="text-sm font-medium">{match.user2.name}</div>
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <Badge
                          variant={
                            match.status === "active"
                              ? "default"
                              : match.status === "blocked"
                                ? "destructive"
                                : "outline"
                          }
                          className={
                            match.status === "active"
                              ? "bg-green-500"
                              : match.status === "inactive"
                                ? "border-yellow-500 text-yellow-500"
                                : ""
                          }
                        >
                          {match.status.charAt(0).toUpperCase() + match.status.slice(1)}
                        </Badge>
                      </td>
                      <td className="py-3 px-4 hidden md:table-cell">
                        <div className="flex items-center gap-2">
                          <Calendar className="h-4 w-4 text-muted-foreground" />
                          <span>{match.matchDate}</span>
                        </div>
                      </td>
                      <td className="py-3 px-4 hidden lg:table-cell">
                        <div className="flex items-center gap-2">
                          <Heart className="h-4 w-4 text-primary" />
                          <span>{match.compatibility}%</span>
                        </div>
                      </td>
                      <td className="py-3 px-4 hidden lg:table-cell">
                        <div className="flex items-center gap-2">
                          <Clock className="h-4 w-4 text-muted-foreground" />
                          <span>{match.lastInteraction}</span>
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
                              View Details
                            </DropdownMenuItem>
                            <DropdownMenuItem>View Messages</DropdownMenuItem>
                            <DropdownMenuItem>View User Profiles</DropdownMenuItem>
                            {match.status !== "blocked" ? (
                              <DropdownMenuItem className="text-destructive">Block Match</DropdownMenuItem>
                            ) : (
                              <DropdownMenuItem className="text-green-500">Unblock Match</DropdownMenuItem>
                            )}
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={7} className="py-10 text-center text-muted-foreground">
                      {visibleMatches.length > 0 ? "No matches found matching your criteria." : "Loading matches..."}
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
