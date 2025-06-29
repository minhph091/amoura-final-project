"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Eye } from "lucide-react"
import { useEffect, useState } from "react"

interface Report {
  id: string
  reporter: {
    name: string
    avatar: string
    initials: string
  }
  reported: {
    name: string
    avatar: string
    initials: string
  }
  type: string
  status: "pending" | "resolved" | "dismissed"
  date: string
}

// Random avatar URLs
const avatarUrls = [
  "https://randomuser.me/api/portraits/women/1.jpg",
  "https://randomuser.me/api/portraits/men/1.jpg",
  "https://randomuser.me/api/portraits/women/2.jpg",
  "https://randomuser.me/api/portraits/men/2.jpg",
  "https://randomuser.me/api/portraits/women/3.jpg",
  "https://randomuser.me/api/portraits/men/3.jpg",
  "https://randomuser.me/api/portraits/women/4.jpg",
  "https://randomuser.me/api/portraits/men/4.jpg",
]

const reports: Report[] = [
  {
    id: "REP-1234",
    reporter: {
      name: "Emma Wilson",
      avatar: avatarUrls[0],
      initials: "EW",
    },
    reported: {
      name: "Jake Smith",
      avatar: avatarUrls[1],
      initials: "JS",
    },
    type: "Inappropriate Content",
    status: "pending",
    date: "2 hours ago",
  },
  {
    id: "REP-1235",
    reporter: {
      name: "Michael Chen",
      avatar: avatarUrls[2],
      initials: "MC",
    },
    reported: {
      name: "Olivia Brown",
      avatar: avatarUrls[3],
      initials: "OB",
    },
    type: "Harassment",
    status: "pending",
    date: "5 hours ago",
  },
  {
    id: "REP-1236",
    reporter: {
      name: "Sophia Garcia",
      avatar: avatarUrls[4],
      initials: "SG",
    },
    reported: {
      name: "William Johnson",
      avatar: avatarUrls[5],
      initials: "WJ",
    },
    type: "Fake Profile",
    status: "resolved",
    date: "1 day ago",
  },
  {
    id: "REP-1237",
    reporter: {
      name: "Liam Taylor",
      avatar: avatarUrls[6],
      initials: "LT",
    },
    reported: {
      name: "Ava Martinez",
      avatar: avatarUrls[7],
      initials: "AM",
    },
    type: "Inappropriate Messages",
    status: "dismissed",
    date: "2 days ago",
  },
]

export function RecentReports() {
  const [visibleReports, setVisibleReports] = useState<Report[]>([])

  useEffect(() => {
    // Simulate loading reports with a delay
    const timer = setTimeout(() => {
      setVisibleReports(reports)
    }, 500)

    return () => clearTimeout(timer)
  }, [])

  return (
    <Card className="card-hover">
      <CardHeader>
        <CardTitle>Recent Reports</CardTitle>
        <CardDescription>Latest user reports that need attention</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {visibleReports.length > 0 ? (
            visibleReports.map((report) => (
              <div
                key={report.id}
                className="flex items-center justify-between p-4 rounded-lg border hover:bg-muted/30 animate-fade-in"
              >
                <div className="flex items-center gap-4">
                  <div className="flex -space-x-2">
                    <Avatar className="border-2 border-background">
                      <AvatarImage src={report.reporter.avatar || "/placeholder.svg"} alt={report.reporter.name} />
                      <AvatarFallback>{report.reporter.initials}</AvatarFallback>
                    </Avatar>
                    <Avatar className="border-2 border-background">
                      <AvatarImage src={report.reported.avatar || "/placeholder.svg"} alt={report.reported.name} />
                      <AvatarFallback>{report.reported.initials}</AvatarFallback>
                    </Avatar>
                  </div>
                  <div>
                    <div className="font-medium">{report.id}</div>
                    <div className="text-sm text-muted-foreground">{report.type}</div>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <Badge
                    variant={
                      report.status === "pending" ? "outline" : report.status === "resolved" ? "default" : "secondary"
                    }
                    className={
                      report.status === "pending"
                        ? "border-yellow-500 text-yellow-500"
                        : report.status === "resolved"
                          ? "bg-green-500"
                          : ""
                    }
                  >
                    {report.status.charAt(0).toUpperCase() + report.status.slice(1)}
                  </Badge>
                  <div className="text-sm text-muted-foreground hidden md:block">{report.date}</div>
                  <Button variant="ghost" size="icon">
                    <Eye className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            ))
          ) : (
            <div className="flex items-center justify-center h-40 text-muted-foreground">Loading reports...</div>
          )}
        </div>
      </CardContent>
    </Card>
  )
}
