
"use client"
import { reportService } from "@/src/services/report.service";
import { userService } from "@/src/services/user.service";
import { useLanguage } from "@/src/contexts/LanguageContext";

import { useState, useEffect } from "react"
import { Card, CardContent } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Search, Filter, MoreHorizontal, Eye, UserX, CheckCircle, XCircle, Calendar } from "lucide-react"

interface Report {
  id: string
  reporter: {
    id: string
    name: string
    avatar: string
    initials: string
  }
  reported: {
    id: string
    name: string
    avatar: string
    initials: string
  }
  type: string
  description: string
  status: "pending" | "resolved" | "dismissed"
  date: string
  assignedTo?: string
}



export function ReportManagement() {
  const { t } = useLanguage();
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);
  const [reportDetailsOpen, setReportDetailsOpen] = useState(false);
  const [suspendDialogOpen, setSuspendDialogOpen] = useState(false);
  const [resolveDialogOpen, setResolveDialogOpen] = useState(false);
  const [dismissDialogOpen, setDismissDialogOpen] = useState(false);
  const [visibleReports, setVisibleReports] = useState<Report[]>([]);
  const [activeTab, setActiveTab] = useState("all");
  const [loading, setLoading] = useState(false);
  const [refreshKey, setRefreshKey] = useState(0);

  useEffect(() => {
    let mounted = true;
    setLoading(true);
    reportService.getReports({ status: statusFilter === "all" ? undefined : statusFilter })
      .then((res) => {
        if (!mounted) return;
        if (res.success && res.data) {
          setVisibleReports(res.data.map((r: any) => ({
            id: r.id.toString(),
            reporter: {
              id: r.reporterId?.toString() || "",
              name: r.reporterName || "Unknown",
              avatar: r.reporterAvatar || "",
              initials: r.reporterInitials || "?"
            },
            reported: {
              id: r.reportedUserId?.toString() || "",
              name: r.reportedUserName || "Unknown",
              avatar: r.reportedUserAvatar || "",
              initials: r.reportedUserInitials || "?"
            },
            type: r.type,
            description: r.reason,
            status: r.status,
            date: r.createdAt,
            assignedTo: r.resolvedBy ? r.resolvedBy.toString() : undefined
          })));
        } else {
          setVisibleReports([]);
        }
        setLoading(false);
      })
      .catch(() => {
        if (mounted) {
          setVisibleReports([]);
          setLoading(false);
        }
      });
    return () => { mounted = false; };
  }, [statusFilter, refreshKey]);

  const filteredReports = visibleReports.filter((report) => {
    const matchesSearch =
      report.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      report.reporter.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      report.reported.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      report.type.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesSearch;
  });

  const pendingReports = filteredReports.filter((report) => report.status === "pending");
  const resolvedReports = filteredReports.filter((report) => report.status === "resolved");
  const dismissedReports = filteredReports.filter((report) => report.status === "dismissed");

  const handleViewReport = (report: Report) => {
    setSelectedReport(report)
    setReportDetailsOpen(true)
  }

  const handleSuspendUser = (report: Report) => {
    setSelectedReport(report)
    setSuspendDialogOpen(true)
  }

  const handleResolveReport = (report: Report) => {
    setSelectedReport(report)
    setResolveDialogOpen(true)
  }

  const handleDismissReport = (report: Report) => {
    setSelectedReport(report)
    setDismissDialogOpen(true)
  }

  const confirmSuspend = async () => {
    if (!selectedReport) return;
    setLoading(true);
    try {
      await userService.suspendUser(selectedReport.reported.id);
      setSuspendDialogOpen(false);
      setSelectedReport(null);
      setRefreshKey((k) => k + 1);
    } catch {
      setSuspendDialogOpen(false);
    } finally {
      setLoading(false);
    }
  };

  const confirmResolve = async () => {
    if (!selectedReport) return;
    setLoading(true);
    try {
      await reportService.resolveReport(selectedReport.id);
      setResolveDialogOpen(false);
      setSelectedReport(null);
      setRefreshKey((k) => k + 1);
    } catch {
      setResolveDialogOpen(false);
    } finally {
      setLoading(false);
    }
  };

  const confirmDismiss = async () => {
    if (!selectedReport) return;
    setLoading(true);
    try {
      await reportService.rejectReport(selectedReport.id);
      setDismissDialogOpen(false);
      setSelectedReport(null);
      setRefreshKey((k) => k + 1);
    } catch {
      setDismissDialogOpen(false);
    } finally {
      setLoading(false);
    }
  };

  const renderReportsList = (reports: Report[]) => {
    if (reports.length === 0) {
      return (
        <div className="flex items-center justify-center h-40 bg-muted/10 rounded-lg">
          <p className="text-muted-foreground">{t.noDataAvailable}</p>
        </div>
      );
    }
    // ...existing code for table rendering...
    return (
      <div className="bg-card rounded-lg border shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full">
            {/* ...existing code for table head and body... */}
            <thead>
              <tr className="border-b bg-muted/40">
                <th className="text-left py-4 px-4 font-bold text-base">{t.reportId}</th>
                <th className="text-left py-4 px-4 font-bold text-base">{t.reportedUser}</th>
                <th className="text-left py-4 px-4 font-bold text-base">{t.type}</th>
                <th className="text-left py-4 px-4 font-bold text-base">{t.status}</th>
                <th className="text-left py-4 px-4 font-bold text-base hidden md:table-cell">{t.date}</th>
                <th className="text-right py-4 px-4 font-bold text-base">{t.actions}</th>
              </tr>
            </thead>
            <tbody>
              {reports.map((report) => (
                <tr
                  key={report.id}
                  className={`border-b animate-fade-in hover:bg-muted/20 ${
                    report.status === "pending"
                      ? "bg-amber-50/30 dark:bg-amber-950/10"
                      : report.status === "resolved"
                        ? "bg-green-50/30 dark:bg-green-950/10"
                        : ""
                  }`}
                >
                  <td className="py-3 px-4 font-medium">{report.id}</td>
                  <td className="py-3 px-4">
                    <div className="flex items-center gap-3">
                      <Avatar>
                        <AvatarImage src={report.reported.avatar} alt={report.reported.name} />
                        <AvatarFallback>{report.reported.initials}</AvatarFallback>
                      </Avatar>
                      <div className="font-medium">{report.reported.name}</div>
                    </div>
                  </td>
                  <td className="py-3 px-4">{report.type}</td>
                  <td className="py-3 px-4">
                    <Badge
                      variant={
                        report.status === "pending" ? "outline" : report.status === "resolved" ? "default" : "secondary"
                      }
                      className={
                        report.status === "pending"
                          ? "border-amber-500 text-amber-500 dark:border-amber-400 dark:text-amber-400"
                          : report.status === "resolved"
                            ? "bg-green-500"
                            : ""
                      }
                    >
                      {report.status.charAt(0).toUpperCase() + report.status.slice(1)}
                    </Badge>
                  </td>
                  <td className="py-3 px-4 hidden md:table-cell">
                    <div className="flex items-center">
                      <Calendar className="h-4 w-4 mr-1.5 text-muted-foreground" />
                      {report.date}
                    </div>
                  </td>
                  <td className="py-3 px-4 text-right">
                    <div className="flex justify-end gap-2">
                      <Button variant="view" size="icon" onClick={() => handleViewReport(report)}>
                        <Eye className="h-4 w-4" />
                      </Button>
                      {report.status === "pending" && (
                        <>
                          <Button
                            variant="success"
                            size="icon"
                            onClick={() => handleResolveReport(report)}
                          >
                            <CheckCircle className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="cancel"
                            size="icon"
                            onClick={() => handleDismissReport(report)}
                          >
                            <XCircle className="h-4 w-4" />
                          </Button>
                        </>
                      )}
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem onClick={() => handleViewReport(report)}>{t.viewDetails}</DropdownMenuItem>
                          {report.status === "pending" && (
                            <>
                              <DropdownMenuItem onClick={() => handleResolveReport(report)}>
                                {t.markAsResolved}
                              </DropdownMenuItem>
                              <DropdownMenuItem onClick={() => handleDismissReport(report)}>
                                {t.dismissReport}
                              </DropdownMenuItem>
                              <DropdownMenuItem className="text-destructive" onClick={() => handleSuspendUser(report)}>
                                {t.suspendUser}
                              </DropdownMenuItem>
                            </>
                          )}
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    );
  };

  return (
    <div className="space-y-6">
      {/* Alert about reports feature */}
      <Card className="border-orange-200 bg-orange-50">
        <CardContent className="p-4">
          <div className="flex items-center gap-3">
            <div className="w-3 h-3 bg-orange-500 rounded-full"></div>
            <div>
              <h4 className="font-medium text-orange-800">{t.reportManagement}</h4>
              <p className="text-sm text-orange-700">
                {t.featureComingSoon}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row gap-4 mb-6">
            <div className="relative flex-1">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
              <Input
                type="search"
                placeholder={t.searchReports}
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
                    <SelectValue placeholder={t.filterByStatus} />
                  </div>
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">{t.allReports}</SelectItem>
                  <SelectItem value="pending">{t.pending}</SelectItem>
                  <SelectItem value="resolved">{t.resolved}</SelectItem>
                  <SelectItem value="dismissed">{t.dismissed}</SelectItem>
                </SelectContent>
              </Select>
              <Button>{t.export}</Button>
            </div>
          </div>

          <Tabs
            defaultValue="all"
            value={activeTab}
            onValueChange={(value) => {
              setActiveTab(value)
              if (value !== "all") {
                setStatusFilter(value)
              } else {
                setStatusFilter("all")
              }
            }}
            className="space-y-4"
          >
            <TabsList className="bg-muted/20 p-1">
              <TabsTrigger value="all" className="data-[state=active]:bg-background">
                {t.allReports}
                <Badge className="ml-2 bg-primary">{filteredReports.length}</Badge>
              </TabsTrigger>
              <TabsTrigger value="pending" className="data-[state=active]:bg-background">
                {t.pending}
                <Badge className="ml-2 border-amber-500 text-amber-500 bg-transparent">{pendingReports.length}</Badge>
              </TabsTrigger>
              <TabsTrigger value="resolved" className="data-[state=active]:bg-background">
                {t.resolved}
                <Badge className="ml-2 bg-green-500">{resolvedReports.length}</Badge>
              </TabsTrigger>
              <TabsTrigger value="dismissed" className="data-[state=active]:bg-background">
                {t.dismissed}
                <Badge className="ml-2 bg-secondary">{dismissedReports.length}</Badge>
              </TabsTrigger>
            </TabsList>

            <TabsContent value="all" className="m-0 space-y-4">
              {loading ? (
                <div className="py-10 text-center text-muted-foreground">{t.loadingText}</div>
              ) : (
                renderReportsList(filteredReports)
              )}
            </TabsContent>

            <TabsContent value="pending" className="m-0 space-y-4">
              {loading ? (
                <div className="py-10 text-center text-muted-foreground">{t.loadingText}</div>
              ) : (
                renderReportsList(pendingReports)
              )}
            </TabsContent>

            <TabsContent value="resolved" className="m-0 space-y-4">
              {loading ? (
                <div className="py-10 text-center text-muted-foreground">{t.loadingText}</div>
              ) : (
                renderReportsList(resolvedReports)
              )}
            </TabsContent>

            <TabsContent value="dismissed" className="m-0 space-y-4">
              {loading ? (
                <div className="py-10 text-center text-muted-foreground">{t.loadingText}</div>
              ) : (
                renderReportsList(dismissedReports)
              )}
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>

      {/* Report Details Dialog */}
      <Dialog open={reportDetailsOpen} onOpenChange={setReportDetailsOpen}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>{t.reportDetails}</DialogTitle>
            <DialogDescription>{t.reportDetailsDescription}</DialogDescription>
          </DialogHeader>

          {selectedReport && (
            <div className="space-y-6 py-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-4">
                  <div>
                    <h3 className="text-sm font-medium">{t.reportInformation}</h3>
                    <div className="mt-2 space-y-2 border rounded-lg p-4 bg-muted/10">
                      <div className="flex justify-between">
                        <span className="text-sm text-muted-foreground">{t.reportId}:</span>
                        <span className="text-sm font-medium">{selectedReport.id}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-sm text-muted-foreground">{t.type}:</span>
                        <span className="text-sm font-medium">{selectedReport.type}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-sm text-muted-foreground">{t.date}:</span>
                        <span className="text-sm font-medium">{selectedReport.date}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-sm text-muted-foreground">{t.status}:</span>
                        <Badge
                          variant={
                            selectedReport.status === "pending"
                              ? "outline"
                              : selectedReport.status === "resolved"
                                ? "default"
                                : "secondary"
                          }
                          className={
                            selectedReport.status === "pending"
                              ? "border-amber-500 text-amber-500"
                              : selectedReport.status === "resolved"
                                ? "bg-green-500"
                                : ""
                          }
                        >
                          {selectedReport.status.charAt(0).toUpperCase() + selectedReport.status.slice(1)}
                        </Badge>
                      </div>
                      {selectedReport.assignedTo && (
                        <div className="flex justify-between">
                          <span className="text-sm text-muted-foreground">{t.assignedTo}:</span>
                          <span className="text-sm font-medium">{selectedReport.assignedTo}</span>
                        </div>
                      )}
                    </div>
                  </div>

                  <div>
                    <h3 className="text-sm font-medium">{t.reporter}</h3>
                    <div className="mt-2 flex items-center gap-3 border rounded-lg p-4 bg-muted/10">
                      <Avatar>
                        <AvatarImage
                          src={selectedReport.reporter.avatar}
                          alt={selectedReport.reporter.name}
                        />
                        <AvatarFallback>{selectedReport.reporter.initials}</AvatarFallback>
                      </Avatar>
                      <div>
                        <p className="text-sm font-medium">{selectedReport.reporter.name}</p>
                        <p className="text-xs text-muted-foreground">ID: {selectedReport.reporter.id}</p>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="space-y-4">
                  <div>
                    <h3 className="text-sm font-medium">{t.reportedUser}</h3>
                    <div className="mt-2 flex items-center gap-3 border rounded-lg p-4 bg-muted/10">
                      <Avatar>
                        <AvatarImage
                          src={selectedReport.reported.avatar}
                          alt={selectedReport.reported.name}
                        />
                        <AvatarFallback>{selectedReport.reported.initials}</AvatarFallback>
                      </Avatar>
                      <div>
                        <p className="text-sm font-medium">{selectedReport.reported.name}</p>
                        <p className="text-xs text-muted-foreground">ID: {selectedReport.reported.id}</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div>
                <h3 className="text-sm font-medium">{t.description}</h3>
                <p className="mt-2 text-sm border rounded-md p-4 bg-muted/10">{selectedReport.description}</p>
              </div>

              {selectedReport.status === "pending" && (
                <div className="flex flex-col sm:flex-row gap-3">
                  <Button
                    className="flex-1"
                    onClick={() => {
                      setReportDetailsOpen(false)
                      handleResolveReport(selectedReport)
                    }}
                  >
                    <CheckCircle className="h-4 w-4 mr-2" />
                    {t.markAsResolved}
                  </Button>
                  <Button
                    variant="cancel"
                    className="flex-1"
                    onClick={() => {
                      setReportDetailsOpen(false)
                      handleDismissReport(selectedReport)
                    }}
                  >
                    <XCircle className="h-4 w-4 mr-2" />
                    {t.dismissReport}
                  </Button>
                  <Button
                    variant="suspend"
                    className="flex-1"
                    onClick={() => {
                      setReportDetailsOpen(false)
                      handleSuspendUser(selectedReport)
                    }}
                  >
                    <UserX className="h-4 w-4 mr-2" />
                    {t.suspendUser}
                  </Button>
                </div>
              )}
            </div>
          )}

          <DialogFooter>
            <Button variant="outline" onClick={() => setReportDetailsOpen(false)}>
              {t.close}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Suspend User Dialog */}
      <Dialog open={suspendDialogOpen} onOpenChange={setSuspendDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t.suspendUserTitle}</DialogTitle>
            <DialogDescription>
              {t.suspendUserDescription}
            </DialogDescription>
          </DialogHeader>

          {selectedReport && (
            <div className="flex items-center gap-4 py-4">
              <Avatar>
                <AvatarImage
                  src={selectedReport.reported.avatar}
                  alt={selectedReport.reported.name}
                />
                <AvatarFallback>{selectedReport.reported.initials}</AvatarFallback>
              </Avatar>
              <div>
                <p className="font-medium">{selectedReport.reported.name}</p>
                <p className="text-sm text-muted-foreground">ID: {selectedReport.reported.id}</p>
              </div>
            </div>
          )}

          <div className="space-y-4">
            <div>
              <label htmlFor="reason" className="text-sm font-medium">
                {t.suspensionReason}
              </label>
              <Select defaultValue={selectedReport?.type.toLowerCase().replace(/\s+/g, "-") || "inappropriate"}>
                <SelectTrigger id="reason">
                  <SelectValue placeholder={t.selectAReason} />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="inappropriate">{t.inappropriateContent}</SelectItem>
                  <SelectItem value="harassment">{t.harassment}</SelectItem>
                  <SelectItem value="fake-profile">{t.fakeProfile}</SelectItem>
                  <SelectItem value="underage">{t.underageUser}</SelectItem>
                  <SelectItem value="other">{t.other}</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div>
              <label htmlFor="duration" className="text-sm font-medium">
                {t.suspensionDuration}
              </label>
              <Select defaultValue="7">
                <SelectTrigger id="duration">
                  <SelectValue placeholder={t.selectDuration} />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="1">{t.oneDay}</SelectItem>
                  <SelectItem value="3">{t.threeDays}</SelectItem>
                  <SelectItem value="7">{t.sevenDays}</SelectItem>
                  <SelectItem value="30">{t.thirtyDays}</SelectItem>
                  <SelectItem value="permanent">{t.permanent}</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setSuspendDialogOpen(false)}>
              {t.cancel}
            </Button>
            <Button variant="destructive" onClick={confirmSuspend}>
              {t.suspendUser}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Resolve Report Dialog */}
      <Dialog open={resolveDialogOpen} onOpenChange={setResolveDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t.resolveReportTitle}</DialogTitle>
            <DialogDescription>
              {t.resolveReportDescription}
            </DialogDescription>
          </DialogHeader>

          {selectedReport && (
            <div className="py-4">
              <div className="flex items-center gap-4 mb-4">
                <Avatar>
                  <AvatarImage
                    src={selectedReport.reported.avatar}
                    alt={selectedReport.reported.name}
                  />
                  <AvatarFallback>{selectedReport.reported.initials}</AvatarFallback>
                </Avatar>
                <div>
                  <p className="font-medium">{selectedReport.reported.name}</p>
                  <p className="text-sm text-muted-foreground">{t.reportId}: {selectedReport.id}</p>
                </div>
              </div>

              <div className="space-y-2">
                <p className="text-sm font-medium">{t.reportType}:</p>
                <p className="text-sm text-muted-foreground">{selectedReport.type}</p>
              </div>
            </div>
          )}

          <div className="space-y-4">
            <div>
              <label htmlFor="resolution" className="text-sm font-medium">
                {t.resolutionNotes}
              </label>
              <Input id="resolution" placeholder={t.enterResolutionDetails} />
            </div>

            <div className="flex items-center space-x-2">
              <input type="checkbox" id="notify" className="rounded" />
              <label htmlFor="notify" className="text-sm">
                {t.notifyReporter}
              </label>
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setResolveDialogOpen(false)}>
              {t.cancel}
            </Button>
            <Button onClick={confirmResolve}>{t.resolveReport}</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Dismiss Report Dialog */}
      <Dialog open={dismissDialogOpen} onOpenChange={setDismissDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t.dismissReportTitle}</DialogTitle>
            <DialogDescription>{t.dismissReportDescription}</DialogDescription>
          </DialogHeader>

          {selectedReport && (
            <div className="py-4">
              <div className="flex items-center gap-4 mb-4">
                <Avatar>
                  <AvatarImage
                    src={selectedReport.reported.avatar || "/placeholder.svg"}
                    alt={selectedReport.reported.name}
                  />
                  <AvatarFallback>{selectedReport.reported.initials}</AvatarFallback>
                </Avatar>
                <div>
                  <p className="font-medium">{selectedReport.reported.name}</p>
                  <p className="text-sm text-muted-foreground">{t.reportId}: {selectedReport.id}</p>
                </div>
              </div>

              <div className="space-y-2">
                <p className="text-sm font-medium">{t.reportType}:</p>
                <p className="text-sm text-muted-foreground">{selectedReport.type}</p>
              </div>
            </div>
          )}

          <div className="space-y-4">
            <div>
              <label htmlFor="dismissReason" className="text-sm font-medium">
                {t.reasonForDismissal}
              </label>
              <Select defaultValue="no-violation">
                <SelectTrigger id="dismissReason">
                  <SelectValue placeholder={t.selectAReason} />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="no-violation">{t.noViolationFound}</SelectItem>
                  <SelectItem value="insufficient">{t.insufficientEvidence}</SelectItem>
                  <SelectItem value="duplicate">{t.duplicateReport}</SelectItem>
                  <SelectItem value="misunderstanding">{t.misunderstanding}</SelectItem>
                  <SelectItem value="other">{t.other}</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div>
              <label htmlFor="dismissNotes" className="text-sm font-medium">
                {t.additionalNotes}
              </label>
              <Input id="dismissNotes" placeholder={t.enterAdditionalDetails} />
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setDismissDialogOpen(false)}>
              {t.cancel}
            </Button>
            <Button variant="secondary" onClick={confirmDismiss}>
              {t.dismissReport}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
