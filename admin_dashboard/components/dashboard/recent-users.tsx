"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { MoreHorizontal } from "lucide-react"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { useEffect, useState } from "react"

interface User {
  id: string
  name: string
  email: string
  avatar: string
  initials: string
  status: "active" | "suspended" | "pending"
  joinDate: string
  location: string
}

// Random avatar URLs
const avatarUrls = [
  "https://randomuser.me/api/portraits/women/5.jpg",
  "https://randomuser.me/api/portraits/men/5.jpg",
  "https://randomuser.me/api/portraits/women/6.jpg",
  "https://randomuser.me/api/portraits/men/6.jpg",
  "https://randomuser.me/api/portraits/women/7.jpg",
  "https://randomuser.me/api/portraits/men/7.jpg",
  "https://randomuser.me/api/portraits/women/8.jpg",
  "https://randomuser.me/api/portraits/men/8.jpg",
]

const users: User[] = [
  {
    id: "U-7823",
    name: "Sarah Johnson",
    email: "sarah.j@example.com",
    avatar: avatarUrls[0],
    initials: "SJ",
    status: "active",
    joinDate: "May 12, 2023",
    location: "New York, USA",
  },
  {
    id: "U-7824",
    name: "Alex Wong",
    email: "alex.w@example.com",
    avatar: avatarUrls[1],
    initials: "AW",
    status: "active",
    joinDate: "May 11, 2023",
    location: "Toronto, Canada",
  },
  {
    id: "U-7825",
    name: "Maria Garcia",
    email: "maria.g@example.com",
    avatar: avatarUrls[2],
    initials: "MG",
    status: "pending",
    joinDate: "May 10, 2023",
    location: "Madrid, Spain",
  },
  {
    id: "U-7826",
    name: "James Smith",
    email: "james.s@example.com",
    avatar: avatarUrls[3],
    initials: "JS",
    status: "suspended",
    joinDate: "May 9, 2023",
    location: "London, UK",
  },
  {
    id: "U-7827",
    name: "Aisha Patel",
    email: "aisha.p@example.com",
    avatar: avatarUrls[4],
    initials: "AP",
    status: "active",
    joinDate: "May 8, 2023",
    location: "Mumbai, India",
  },
]

export function RecentUsers() {
  const [visibleUsers, setVisibleUsers] = useState<User[]>([])

  useEffect(() => {
    // Simulate loading users with a delay
    const timer = setTimeout(() => {
      setVisibleUsers(users)
    }, 700)

    return () => clearTimeout(timer)
  }, [])

  return (
    <Card className="card-hover">
      <CardHeader>
        <CardTitle>Recent Users</CardTitle>
        <CardDescription>Latest user registrations</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b bg-muted/40">
                <th className="text-left py-4 px-4 font-bold text-base">User</th>
                <th className="text-left py-4 px-4 font-bold text-base">Status</th>
                <th className="text-left py-4 px-4 font-bold text-base hidden md:table-cell">Join Date</th>
                <th className="text-left py-4 px-4 font-bold text-base hidden lg:table-cell">Location</th>
                <th className="text-right py-4 px-4 font-bold text-base">Actions</th>
              </tr>
            </thead>
            <tbody>
              {visibleUsers.length > 0 ? (
                visibleUsers.map((user) => (
                  <tr key={user.id} className="border-b animate-fade-in">
                    <td className="py-3 px-4">
                      <div className="flex items-center gap-3">
                        <Avatar>
                          <AvatarImage src={user.avatar || "/placeholder.svg"} alt={user.name} />
                          <AvatarFallback>{user.initials}</AvatarFallback>
                        </Avatar>
                        <div>
                          <div className="font-medium">{user.name}</div>
                          <div className="text-sm text-muted-foreground">{user.email}</div>
                        </div>
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      <Badge
                        variant={
                          user.status === "active" ? "default" : user.status === "suspended" ? "destructive" : "outline"
                        }
                        className={
                          user.status === "active"
                            ? "bg-green-500"
                            : user.status === "pending"
                              ? "border-yellow-500 text-yellow-500"
                              : ""
                        }
                      >
                        {user.status.charAt(0).toUpperCase() + user.status.slice(1)}
                      </Badge>
                    </td>
                    <td className="py-3 px-4 hidden md:table-cell">{user.joinDate}</td>
                    <td className="py-3 px-4 hidden lg:table-cell">{user.location}</td>
                    <td className="py-3 px-4 text-right">
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem>View Profile</DropdownMenuItem>
                          <DropdownMenuItem>Edit User</DropdownMenuItem>
                          <DropdownMenuItem className="text-destructive">Suspend User</DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={5} className="py-10 text-center text-muted-foreground">
                    Loading users...
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  )
}
