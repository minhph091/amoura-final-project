"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  CardFooter,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Eye, CheckCircle, XCircle, Calendar, ArrowRight } from "lucide-react";

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
  description: string;
}

import { reportService } from "@/src/services/report.service";

export function RecentReportsWidget() {
  const [visibleReports, setVisibleReports] = useState<any[]>([]);
  const [selectedReport, setSelectedReport] = useState<any | null>(null);
  const [isDetailsOpen, setIsDetailsOpen] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    const fetchReports = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await reportService.getReports({ page: 1, limit: 10 });
        if (!response.success)
          throw new Error(response.error || "Failed to fetch reports");
        // Map backend data to UI type if needed
        const backendReports = response.data ?? [];
        const uiReports = backendReports.map((r: any) => ({
          id: String(r.id),
          reporter: {
            name: r.reporterName || "Unknown",
            avatar: r.reporterAvatar || "",
            initials:
              r.reporterInitials || (r.reporterName ? r.reporterName[0] : "U"),
          },
          reported: {
            name: r.reportedName || "Unknown",
            avatar: r.reportedAvatar || "",
            initials:
              r.reportedInitials || (r.reportedName ? r.reportedName[0] : "U"),
          },
          type: r.type || "other",
          status: r.status || "pending",
          date: r.createdAt || "",
          description: r.reason || "",
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

  const handleViewDetails = (report: any) => {
    setSelectedReport(report);
    setIsDetailsOpen(true);
  };

  const pendingReports = visibleReports.filter(
    (report) => report.status === "pending"
  );
  const resolvedReports = visibleReports.filter(
    (report) => report.status === "resolved"
  );
  const dismissedReports = visibleReports.filter(
    (report) => report.status === "dismissed"
  );

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
    <>
      <Card className="card-hover">
        <CardHeader>
          <CardTitle>Recent Reports</CardTitle>
          <CardDescription>
            Latest user reports that need attention
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Tabs defaultValue="pending" className="space-y-4">
            <TabsList>
              <TabsTrigger value="pending">
                Pending
                {pendingReports.length > 0 && (
                  <Badge color="error" className="ml-2">
                    {pendingReports.length}
                  </Badge>
                )}
              </TabsTrigger>
              <TabsTrigger value="resolved">Resolved</TabsTrigger>
              <TabsTrigger value="dismissed">Dismissed</TabsTrigger>
            </TabsList>

            <TabsContent value="pending" className="space-y-4">
              {pendingReports.length > 0 ? (
                pendingReports.map((report) => (
                  <div
                    key={report.id}
                    className="flex items-center justify-between p-4 rounded-lg border border-amber-200 bg-amber-50 dark:border-amber-900 dark:bg-amber-950/30 hover:bg-amber-100 dark:hover:bg-amber-900/40 transition-colors animate-fade-in"
                  >
                    <div className="flex items-center gap-4">
                      <div className="flex -space-x-2">
                        <Avatar className="border-2 border-background">
                          <AvatarImage
                            src={report.reporter?.avatar || "/placeholder.svg"}
                            alt={report.reporter?.name}
                          />
                          <AvatarFallback>
                            {report.reporter?.initials}
                          </AvatarFallback>
                        </Avatar>
                        <Avatar className="border-2 border-background">
                          <AvatarImage
                            src={report.reported?.avatar || "/placeholder.svg"}
                            alt={report.reported?.name}
                          />
                          <AvatarFallback>
                            {report.reported?.initials}
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
                        color="warning"
                        className="border-amber-500 text-amber-500 dark:border-amber-400 dark:text-amber-400"
                      >
                        Pending
                      </Badge>
                      <div className="text-sm text-muted-foreground hidden md:block">
                        {report.date}
                      </div>
                      <Button
                        className="btn-ghost btn-icon"
                        onClick={() => handleViewDetails(report)}
                      >
                        <Eye className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8 text-muted-foreground">
                  {visibleReports.length > 0
                    ? "No pending reports found."
                    : "Loading reports..."}
                </div>
              )}
            </TabsContent>

            <TabsContent value="resolved" className="space-y-4">
              {resolvedReports.length > 0 ? (
                resolvedReports.map((report) => (
                  <div
                    key={report.id}
                    className="flex items-center justify-between p-4 rounded-lg border border-green-200 bg-green-50 dark:border-green-900 dark:bg-green-950/30 hover:bg-green-100 dark:hover:bg-green-900/40 transition-colors animate-fade-in"
                  >
                    <div className="flex items-center gap-4">
                      <div className="flex -space-x-2">
                        <Avatar className="border-2 border-background">
                          <AvatarImage
                            src={report.reporter?.avatar || "/placeholder.svg"}
                            alt={report.reporter?.name}
                          />
                          <AvatarFallback>
                            {report.reporter?.initials}
                          </AvatarFallback>
                        </Avatar>
                        <Avatar className="border-2 border-background">
                          <AvatarImage
                            src={report.reported?.avatar || "/placeholder.svg"}
                            alt={report.reported?.name}
                          />
                          <AvatarFallback>
                            {report.reported?.initials}
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
                      <Badge color="success" className="bg-green-500">
                        Resolved
                      </Badge>
                      <div className="text-sm text-muted-foreground hidden md:block">
                        {report.date}
                      </div>
                      <Button
                        className="btn-ghost btn-icon"
                        onClick={() => handleViewDetails(report)}
                      >
                        <Eye className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8 text-muted-foreground">
                  {visibleReports.length > 0
                    ? "No resolved reports found."
                    : "Loading reports..."}
                </div>
              )}
            </TabsContent>

            <TabsContent value="dismissed" className="space-y-4">
              {dismissedReports.length > 0 ? (
                dismissedReports.map((report) => (
                  <div
                    key={report.id}
                    className="flex items-center justify-between p-4 rounded-lg border border-muted bg-muted/20 hover:bg-muted/30 transition-colors animate-fade-in"
                  >
                    <div className="flex items-center gap-4">
                      <div className="flex -space-x-2">
                        <Avatar className="border-2 border-background">
                          <AvatarImage
                            src={report.reporter?.avatar || "/placeholder.svg"}
                            alt={report.reporter?.name}
                          />
                          <AvatarFallback>
                            {report.reporter?.initials}
                          </AvatarFallback>
                        </Avatar>
                        <Avatar className="border-2 border-background">
                          <AvatarImage
                            src={report.reported?.avatar || "/placeholder.svg"}
                            alt={report.reported?.name}
                          />
                          <AvatarFallback>
                            {report.reported?.initials}
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
                      <Badge color="default">Dismissed</Badge>
                      <div className="text-sm text-muted-foreground hidden md:block">
                        {report.date}
                      </div>
                      <Button
                        className="btn-ghost btn-icon"
                        onClick={() => handleViewDetails(report)}
                      >
                        <Eye className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8 text-muted-foreground">
                  {visibleReports.length > 0
                    ? "No dismissed reports found."
                    : "Loading reports..."}
                </div>
              )}
            </TabsContent>
          </Tabs>
        </CardContent>
        <CardFooter className="flex justify-end">
          <Button
            className="btn-outline"
            onClick={() => router.push("/dashboard/reports")}
          >
            View All Reports <ArrowRight className="ml-2 h-4 w-4" />
          </Button>
        </CardFooter>
      </Card>

      {/* Report Details Dialog */}
      <Dialog open={isDetailsOpen} onOpenChange={setIsDetailsOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Report Details</DialogTitle>
          </DialogHeader>

          {selectedReport && (
            <div className="space-y-4 py-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <div className="text-sm font-medium">Report ID</div>
                  <div className="flex items-center gap-2 bg-muted p-2 rounded">
                    {selectedReport.id}
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="text-sm font-medium">Date</div>
                  <div className="flex items-center gap-2 bg-muted p-2 rounded">
                    <Calendar className="h-4 w-4 text-muted-foreground" />
                    {selectedReport.date}
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="text-sm font-medium">Report Type</div>
                  <div className="flex items-center gap-2 bg-muted p-2 rounded">
                    {selectedReport.type}
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="text-sm font-medium">Status</div>
                  <div>
                    <Badge
                      color={
                        selectedReport.status === "pending"
                          ? "warning"
                          : selectedReport.status === "resolved"
                          ? "success"
                          : "default"
                      }
                      className={
                        selectedReport.status === "pending"
                          ? "border-amber-500 text-amber-500"
                          : selectedReport.status === "resolved"
                          ? "bg-green-500"
                          : ""
                      }
                    >
                      {selectedReport.status.charAt(0).toUpperCase() +
                        selectedReport.status.slice(1)}
                    </Badge>
                  </div>
                </div>
              </div>

              <div className="space-y-2">
                <div className="text-sm font-medium">Reporter</div>
                <div className="flex items-center gap-3 bg-muted p-2 rounded">
                  <Avatar>
                    <AvatarImage
                      src={
                        selectedReport.reporter?.avatar || "/placeholder.svg"
                      }
                      alt={selectedReport.reporter?.name}
                    />
                    <AvatarFallback>
                      {selectedReport.reporter?.initials}
                    </AvatarFallback>
                  </Avatar>
                  <div>{selectedReport.reporter?.name}</div>
                </div>
              </div>

              <div className="space-y-2">
                <div className="text-sm font-medium">Reported User</div>
                <div className="flex items-center gap-3 bg-muted p-2 rounded">
                  <Avatar>
                    <AvatarImage
                      src={
                        selectedReport.reported?.avatar || "/placeholder.svg"
                      }
                      alt={selectedReport.reported?.name}
                    />
                    <AvatarFallback>
                      {selectedReport.reported?.initials}
                    </AvatarFallback>
                  </Avatar>
                  <div>{selectedReport.reported?.name}</div>
                </div>
              </div>

              <div className="space-y-2">
                <div className="text-sm font-medium">Description</div>
                <div className="bg-muted p-3 rounded text-sm">
                  {selectedReport.description}
                </div>
              </div>
            </div>
          )}

          <DialogFooter className="flex justify-between">
            <div className="flex gap-2">
              {selectedReport?.status === "pending" && (
                <>
                  <Button className="btn-outline gap-1">
                    <XCircle className="h-4 w-4" /> Dismiss
                  </Button>
                  <Button className="gap-1">
                    <CheckCircle className="h-4 w-4" /> Resolve
                  </Button>
                </>
              )}
            </div>
            <Button
              className="btn-outline"
              onClick={() => setIsDetailsOpen(false)}
            >
              Close
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
