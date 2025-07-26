"use client";

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Eye } from "lucide-react";
import { useEffect, useState } from "react";

interface Report {
  id: string;
  reporter: {
    name: string;
    avatar: string;
    initials: string;
  };
  reported: {
    name: string;
    avatar: string;
    initials: string;
  };
  type: string;
  status: "pending" | "resolved" | "dismissed";
  date: string;
}

import { reportService } from "@/src/services/report.service";
import type {
  Report as UIReport,
  ReportStatus,
} from "@/src/types/report.types";

export function RecentReports() {
  const [visibleReports, setVisibleReports] = useState<UIReport[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchReports = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await reportService.getReports({ page: 1, limit: 10 });
        if (!response.success)
          throw new Error(response.error || "Failed to fetch reports");
        // Transform backend reports to UIReport format
        const backendReports = response.data ?? [];
        const uiReports: UIReport[] = backendReports.map((r: any) => ({
          id: String(r.id),
          reporter: {
            id: String(r.reporterId),
            name: r.reporterName || "Unknown",
            avatar: r.reporterAvatar || "",
            initials:
              r.reporterInitials || (r.reporterName ? r.reporterName[0] : "U"),
          },
          reported: {
            id: String(r.reportedUserId),
            name: r.reportedName || "Unknown",
            avatar: r.reportedAvatar || "",
            initials:
              r.reportedInitials || (r.reportedName ? r.reportedName[0] : "U"),
          },
          type: r.type || "other",
          category: r.category || "profile",
          description: r.reason || "",
          status: r.status || "pending",
          date: r.createdAt || "",
          assignedTo: r.assignedTo || "",
          resolvedAt: r.resolvedAt || "",
          resolvedBy: r.resolvedBy || "",
          resolutionNotes: r.resolutionNotes || "",
          severity: r.severity || "low",
          attachments: r.attachments || [],
        }));
        setVisibleReports(uiReports);
      } catch (err: any) {
        setError(err.message || "Unknown error");
      } finally {
        setLoading(false);
      }
    };
    fetchReports();
  }, []);

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Recent Reports</CardTitle>
          <CardDescription>
            Latest user reports that need attention
          </CardDescription>
        </CardHeader>
        <CardContent className="h-40 flex items-center justify-center">
          Loading reports...
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Recent Reports</CardTitle>
        </CardHeader>
        <CardContent className="h-40 flex items-center justify-center text-red-500">
          Error: {error}
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="card-hover">
      <CardHeader>
        <CardTitle>Recent Reports</CardTitle>
        <CardDescription>
          Latest user reports that need attention
        </CardDescription>
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
                      <AvatarImage
                        src={report.reporter.avatar || "/placeholder.svg"}
                        alt={report.reporter.name}
                      />
                      <AvatarFallback>
                        {report.reporter.initials}
                      </AvatarFallback>
                    </Avatar>
                    <Avatar className="border-2 border-background">
                      <AvatarImage
                        src={report.reported.avatar || "/placeholder.svg"}
                        alt={report.reported.name}
                      />
                      <AvatarFallback>
                        {report.reported.initials}
                      </AvatarFallback>
                    </Avatar>
                  </div>
                  <div>
                    <div className="font-medium">{report.id}</div>
                    <div className="text-sm text-muted-foreground">
                      {report.type}
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <Badge
                    className={
                      report.status === "pending"
                        ? "border-yellow-500 text-yellow-500"
                        : report.status === "resolved"
                        ? "bg-green-500 text-white"
                        : report.status === "dismissed"
                        ? "bg-gray-400 text-white"
                        : "bg-gray-300 text-black"
                    }
                  >
                    {report.status
                      ? report.status.charAt(0).toUpperCase() +
                        report.status.slice(1)
                      : "Unknown"}
                  </Badge>
                  <div className="text-sm text-muted-foreground hidden md:block">
                    {report.date}
                  </div>
                  <Button className="btn-ghost btn-icon">
                    <Eye className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            ))
          ) : (
            <div className="flex items-center justify-center h-40 text-muted-foreground">
              No reports found.
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
