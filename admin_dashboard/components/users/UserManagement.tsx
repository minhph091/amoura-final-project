"use client";

import { useState, useEffect } from "react";
import { moderationService } from "@/src/services/moderation.service";
import type { UserManagementData, UserStatusUpdateRequest } from "@/src/services/admin.service";
import { useLanguage } from "@/src/contexts/LanguageContext";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Search, Filter, MoreHorizontal, Eye, UserX, UserCheck, ChevronLeft, ChevronRight, AlertCircle } from "lucide-react";
import { toast } from "@/hooks/use-toast";

export function UserManagement() {
  const { t } = useLanguage();
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [selectedUser, setSelectedUser] = useState<UserManagementData | null>(null);
  const [userDetailsOpen, setUserDetailsOpen] = useState(false);
  const [suspendDialogOpen, setSuspendDialogOpen] = useState(false);
  const [restoreDialogOpen, setRestoreDialogOpen] = useState(false);
  const [users, setUsers] = useState<UserManagementData[]>([]);
  const [loading, setLoading] = useState(true);
  const [suspensionDays, setSuspensionDays] = useState(7);
  const [suspensionReason, setSuspensionReason] = useState("");
  const [permissionError, setPermissionError] = useState<string | null>(null);
  
  // Pagination state
  const [currentCursor, setCurrentCursor] = useState<number | undefined>(undefined);
  const [hasNext, setHasNext] = useState(false);
  const [hasPrevious, setHasPrevious] = useState(false);
  const [nextCursor, setNextCursor] = useState<number | undefined>(undefined);
  const [previousCursor, setPreviousCursor] = useState<number | undefined>(undefined);

  // Search debouncing
  const [searchTimeout, setSearchTimeout] = useState<NodeJS.Timeout | null>(null);

  // Get available actions for current user
  const availableActions = moderationService.getAvailableActions();
  const currentUserRole = moderationService.getCurrentUserRole();

  const fetchUsers = async (cursor?: number, direction: "NEXT" | "PREVIOUS" = "NEXT", search?: string) => {
    setLoading(true);
    setPermissionError(null);
    
    try {
      let response;
      if (search && search.trim()) {
        response = await moderationService.searchUsers(search.trim(), {
          cursor,
          limit: 20,
          direction,
        });
      } else {
        response = await moderationService.getUsers({
          cursor,
          limit: 20,
          direction,
        });
      }

      if (response.success && response.data) {
        setUsers(response.data.data);
        setHasNext(response.data.hasNext);
        setHasPrevious(response.data.hasPrevious);
        setNextCursor(response.data.nextCursor);
        setPreviousCursor(response.data.previousCursor);
      } else {
        // Check if it's a permission error
        if (response.error && response.error.includes("permission")) {
          setPermissionError(response.error);
          setUsers([]);
        } else {
          toast({
            title: t.errorTitle,
            description: response.error || t.failedToLoadUsers,
            variant: "destructive",
          });
          setUsers([]);
        }
      }
    } catch (error) {
      toast({
        title: t.errorTitle,
        description: t.failedToLoadUsers,
        variant: "destructive",
      });
      setUsers([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  // Search with debouncing
  useEffect(() => {
    if (searchTimeout) {
      clearTimeout(searchTimeout);
    }

    const timeout = setTimeout(() => {
      setCurrentCursor(undefined);
      fetchUsers(undefined, "NEXT", searchTerm);
    }, 500);

    setSearchTimeout(timeout);

    return () => {
      if (timeout) clearTimeout(timeout);
    };
  }, [searchTerm]);

  const filteredUsers = (users || []).filter((user) => {
    const matchesStatus =
      statusFilter === "all" ||
      (user.status && user.status.toLowerCase() === statusFilter.toLowerCase());
    return matchesStatus;
  });

  const handleViewUser = async (userId: number) => {
    if (!availableActions.canViewUserDetails) {
      toast({
        title: t.errorTitle,
        description: "You don't have permission to view user details.",
        variant: "destructive",
      });
      return;
    }

    try {
      const response = await moderationService.getUserById(userId.toString());
      if (response.success && response.data) {
        setSelectedUser(response.data);
        setUserDetailsOpen(true);
      } else {
        toast({
          title: t.errorTitle,
          description: response.error || t.failedToLoadUserDetails,
          variant: "destructive",
        });
      }
    } catch (error) {
      toast({
        title: t.errorTitle,
        description: t.failedToLoadUserDetails,
        variant: "destructive",
      });
    }
  };

  const handleSuspendUser = (user: UserManagementData) => {
    setSelectedUser(user);
    setSuspensionReason("");
    setSuspensionDays(7);
    setSuspendDialogOpen(true);
  };

  const handleRestoreUser = (user: UserManagementData) => {
    setSelectedUser(user);
    setRestoreDialogOpen(true);
  };

  const confirmSuspend = async () => {
    if (!selectedUser) return;

    if (!availableActions.canSuspendUsers) {
      toast({
        title: t.errorTitle,
        description: "You don't have permission to suspend users.",
        variant: "destructive",
      });
      return;
    }

    try {
      const request: UserStatusUpdateRequest = {
        status: "SUSPEND",
        reason: suspensionReason || t.suspendedByAdmin,
        suspensionDays: suspensionDays,
      };

      const response = await moderationService.updateUserStatus(selectedUser.id.toString(), request);
      
      if (response.success) {
        toast({
          title: t.userSuspendedTitle,
          description: `${t.userSuspended} ${suspensionDays} ${t.daysAgo}.`,
        });
        setSuspendDialogOpen(false);
        fetchUsers(currentCursor, "NEXT", searchTerm); // Refresh current page
      } else {
        toast({
          title: t.errorTitle,
          description: response.error || t.failedToSuspendUser,
          variant: "destructive",
        });
      }
    } catch (error) {
      toast({
        title: t.errorTitle,
        description: t.failedToSuspendUser,
        variant: "destructive",
      });
    }
  };

  const confirmRestore = async () => {
    if (!selectedUser) return;

    if (!availableActions.canRestoreUsers) {
      toast({
        title: t.errorTitle,
        description: "You don't have permission to restore users.",
        variant: "destructive",
      });
      return;
    }

    try {
      const request: UserStatusUpdateRequest = {
        status: "ACTIVE",
        reason: t.restoredByAdmin,
      };

      const response = await moderationService.updateUserStatus(selectedUser.id.toString(), request);
      
      if (response.success) {
        toast({
          title: t.userRestoredTitle,
          description: t.userRestoredMessage,
        });
        setRestoreDialogOpen(false);
        fetchUsers(currentCursor, "NEXT", searchTerm); // Refresh current page
      } else {
        toast({
          title: t.errorTitle,
          description: response.error || t.failedToRestoreUser,
          variant: "destructive",
        });
      }
    } catch (error) {
      toast({
        title: t.errorTitle,
        description: t.failedToRestoreUser,
        variant: "destructive",
      });
    }
  };

  const handleNextPage = () => {
    if (hasNext && nextCursor !== undefined) {
      setCurrentCursor(nextCursor);
      fetchUsers(nextCursor, "NEXT", searchTerm);
    }
  };

  const handlePreviousPage = () => {
    if (hasPrevious && previousCursor !== undefined) {
      setCurrentCursor(previousCursor);
      fetchUsers(previousCursor, "PREVIOUS", searchTerm);
    }
  };

  const formatDate = (dateString: string) => {
    if (!dateString) return t.unknown;
    try {
      return new Date(dateString).toLocaleDateString();
    } catch {
      return t.unknown;
    }
  };

  return (
    <div className="space-y-6">
      {/* Role and Permission Info */}
      {currentUserRole && (
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <div className="flex items-center gap-2">
            <AlertCircle className="h-4 w-4 text-blue-600" />
            <span className="text-sm font-medium text-blue-800">
              {currentUserRole === "ADMIN" ? "Admin Access" : "Moderator Access"}
            </span>
          </div>
          <p className="text-xs text-blue-600 mt-1">
            {currentUserRole === "ADMIN" 
              ? "You have full administrative privileges." 
              : "You can view and search users, but cannot modify user status. Contact admin for status changes."
            }
          </p>
        </div>
      )}

      {/* Permission Error Message */}
      {permissionError && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4">
          <div className="flex items-center gap-2">
            <AlertCircle className="h-4 w-4 text-red-600" />
            <span className="text-sm font-medium text-red-800">Access Restricted</span>
          </div>
          <p className="text-xs text-red-600 mt-1">{permissionError}</p>
          <p className="text-xs text-red-500 mt-2">
            Please contact your administrator if you need access to user management features.
          </p>
        </div>
      )}

      <Card>
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row gap-4 mb-6">
            <div className="relative flex-1">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
              <Input
                type="search"
                placeholder={t.searchUsersByNameEmailUsername}
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
                  <SelectItem value="all">{t.allStatusesFilter}</SelectItem>
                  <SelectItem value="active">{t.active}</SelectItem>
                  <SelectItem value="suspend">{t.suspended}</SelectItem>
                  <SelectItem value="inactive">{t.inactive}</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b bg-muted/40">
                  <th className="text-left py-4 px-4 font-bold text-base">{t.userColumn}</th>
                  <th className="text-left py-4 px-4 font-bold text-base">{t.contact}</th>
                  <th className="text-left py-4 px-4 font-bold text-base">{t.status}</th>
                  <th className="text-left py-4 px-4 font-bold text-base">{t.activity}</th>
                  <th className="text-right py-4 px-4 font-bold text-base">{t.actions}</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={5} className="py-10 text-center text-muted-foreground">
                      {t.loading}...
                    </td>
                  </tr>
                ) : filteredUsers.length > 0 ? (
                  filteredUsers.map((user) => (
                    <tr key={user.id} className="border-b animate-fade-in">
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-3">
                          <div>
                            <div className="font-medium">
                              {user.firstName && user.lastName
                                ? `${user.firstName} ${user.lastName}`
                                : user.username || `User ${user.id}`
                              }
                            </div>
                            <div className="text-sm text-muted-foreground">ID: {user.id}</div>
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div>
                          <div className="text-sm">{user.email}</div>
                          {user.phoneNumber && (
                            <div className="text-sm text-muted-foreground">{user.phoneNumber}</div>
                          )}
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="space-y-1">
                          {user.status === "SUSPEND" ? (
                            <TooltipProvider>
                              <Tooltip>
                                <TooltipTrigger>
                                  <Badge
                                    variant="destructive"
                                    className="bg-red-500 text-white cursor-pointer"
                                  >
                                    {user.status}
                                    <span className="ml-1 text-xs">🚫</span>
                                  </Badge>
                                </TooltipTrigger>
                                <TooltipContent>
                                  <p>SUSPENDED - Cannot access platform</p>
                                </TooltipContent>
                              </Tooltip>
                            </TooltipProvider>
                          ) : (
                            <Badge
                              variant={
                                user.status === "ACTIVE"
                                  ? "default"
                                  : "outline"
                              }
                              className={
                                user.status === "ACTIVE"
                                  ? "bg-green-500"
                                  : user.status === "INACTIVE"
                                    ? "border-yellow-500 text-yellow-500"
                                    : ""
                              }
                            >
                              {user.status}
                              {user.status === "ACTIVE" && (
                                <span className="ml-1 text-xs">✅</span>
                              )}
                            </Badge>
                          )}
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="text-sm">
                          <div>{t.created}: {formatDate(user.createdAt)}</div>
                          {user.lastLogin && (
                            <div className="text-muted-foreground">
                              {t.lastLogin}: {formatDate(user.lastLogin)}
                            </div>
                          )}
                        </div>
                      </td>
                      <td className="py-3 px-4 text-right">
                        <div className="flex justify-end gap-2">
                          <Button
                            variant="view"
                            size="icon"
                            onClick={() => handleViewUser(user.id)}
                          >
                            <Eye className="h-4 w-4" />
                          </Button>
                          {availableActions.canSuspendUsers && user.status !== "SUSPEND" ? (
                            <Button
                              variant="suspend"
                              size="icon"
                              onClick={() => handleSuspendUser(user)}
                            >
                              <UserX className="h-4 w-4" />
                            </Button>
                          ) : availableActions.canRestoreUsers && user.status === "SUSPEND" ? (
                            <Button
                              variant="restore"
                              size="icon"
                              onClick={() => handleRestoreUser(user)}
                            >
                              <UserCheck className="h-4 w-4" />
                            </Button>
                          ) : null}
                        </div>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={5} className="py-10 text-center text-muted-foreground">
                      {t.noUsersFound}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          <div className="flex items-center justify-between mt-6">
            <div className="text-sm text-muted-foreground">
              {t.totalUsersCount}: {users.length} ({t.currentPage})
            </div>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={handlePreviousPage}
                disabled={!hasPrevious || loading}
              >
                <ChevronLeft className="h-4 w-4 mr-2" />
                {t.previousPage}
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={handleNextPage}
                disabled={!hasNext || loading}
              >
                {t.nextPage}
                <ChevronRight className="h-4 w-4 ml-2" />
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* User Details Dialog */}
      <Dialog open={userDetailsOpen} onOpenChange={setUserDetailsOpen}>
        <DialogContent className="max-w-4xl">
          <DialogHeader className="space-y-2 pb-4">
            <DialogTitle className="text-xl font-bold bg-gradient-to-r from-pink-500 to-blue-600 bg-clip-text text-transparent">
              {t.userDetailsModal}
            </DialogTitle>
            <DialogDescription className="text-gray-600">
              {t.detailedInformationSelectedUser}
            </DialogDescription>
            {currentUserRole === "MODERATOR" && (
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 mt-2">
                <p className="text-xs text-blue-700">
                  <strong>Moderator View:</strong> You can view user details but cannot modify user status.
                </p>
              </div>
            )}
          </DialogHeader>

          {selectedUser && (
            <div className="grid grid-cols-3 gap-4 py-4">
              <div className="space-y-1">
                <p className="text-xs font-semibold text-pink-600">{t.userId}</p>
                <p className="text-sm text-gray-800">{selectedUser.id}</p>
              </div>
              <div className="space-y-1">
                <p className="text-xs font-semibold text-blue-600">{t.username}</p>
                <p className="text-sm text-gray-800">{selectedUser.username || t.unknown}</p>
              </div>
              <div className="space-y-1">
                <p className="text-xs font-semibold text-green-600">{t.email}</p>
                <p className="text-sm text-gray-800 truncate">{selectedUser.email}</p>
              </div>
              
              <div className="space-y-1">
                <p className="text-xs font-semibold text-purple-600">{t.phoneNumber}</p>
                <p className="text-sm text-gray-800">{selectedUser.phoneNumber || t.unknown}</p>
              </div>
              <div className="space-y-1">
                <p className="text-xs font-semibold text-indigo-600">{t.firstName}</p>
                <p className="text-sm text-gray-800">{selectedUser.firstName || t.unknown}</p>
              </div>
              <div className="space-y-1">
                <p className="text-xs font-semibold text-teal-600">{t.lastName}</p>
                <p className="text-sm text-gray-800">{selectedUser.lastName || t.unknown}</p>
              </div>
              
              <div className="space-y-1">
                <p className="text-xs font-semibold text-orange-600">{t.status}</p>
                <Badge className={selectedUser.status === "ACTIVE" ? "bg-green-100 text-green-800 text-xs" : "bg-red-100 text-red-800 text-xs"}>
                  {selectedUser.status}
                </Badge>
              </div>
              <div className="space-y-1">
                <p className="text-xs font-semibold text-cyan-600">{t.hasProfile}</p>
                <Badge className={selectedUser.hasProfile ? "bg-blue-100 text-blue-800 text-xs" : "bg-gray-100 text-gray-800 text-xs"}>
                  {selectedUser.hasProfile ? t.yes : t.no}
                </Badge>
              </div>
              <div className="space-y-1">
                <p className="text-xs font-semibold text-rose-600">{t.photoCount}</p>
                <p className="text-sm text-gray-800">{selectedUser.photoCount}</p>
              </div>
              
              <div className="space-y-1">
                <p className="text-xs font-semibold text-emerald-600">{t.totalMatchesUser}</p>
                <p className="text-sm text-gray-800">{selectedUser.totalMatches}</p>
              </div>
              <div className="space-y-1">
                <p className="text-xs font-semibold text-violet-600">{t.totalMessagesUser}</p>
                <p className="text-sm text-gray-800">{selectedUser.totalMessages}</p>
              </div>
              <div className="space-y-1">
                <p className="text-xs font-semibold text-amber-600">{t.lastLogin}</p>
                <p className="text-sm text-gray-800">{formatDate(selectedUser.lastLogin)}</p>
              </div>
              
              <div className="space-y-1 col-span-3">
                <p className="text-xs font-semibold text-sky-600">{t.createdAt}</p>
                <p className="text-sm text-gray-800">{formatDate(selectedUser.createdAt)}</p>
              </div>
            </div>
          )}

          <DialogFooter className="gap-2 pt-4 border-t">
            <Button 
              variant="outline" 
              onClick={() => setUserDetailsOpen(false)}
              className="px-4 py-2"
            >
              {t.close}
            </Button>
            {availableActions.canSuspendUsers && selectedUser && selectedUser.status !== "SUSPEND" ? (
              <Button
                variant="suspend"
                onClick={() => {
                  setUserDetailsOpen(false);
                  handleSuspendUser(selectedUser);
                }}
                className="px-4 py-2"
              >
                {t.suspendUser}
              </Button>
            ) : (
              availableActions.canRestoreUsers && selectedUser && selectedUser.status === "SUSPEND" && (
                <Button
                  variant="restore"
                  onClick={() => {
                    setUserDetailsOpen(false);
                    handleRestoreUser(selectedUser);
                  }}
                  className="px-4 py-2"
                >
                  {t.restoreUserAction}
                </Button>
              )
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Suspend User Dialog - Only show for ADMIN */}
      {availableActions.canSuspendUsers && (
        <Dialog open={suspendDialogOpen} onOpenChange={setSuspendDialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>⚠️ {t.suspendUserTitle}</DialogTitle>
              <DialogDescription>
                {t.suspendUserDescription}
              </DialogDescription>
            </DialogHeader>

          {selectedUser && (
            <div className="space-y-4">
              <div className="py-4">
                <p className="font-medium">
                  {selectedUser.firstName && selectedUser.lastName
                    ? `${selectedUser.firstName} ${selectedUser.lastName}`
                    : selectedUser.username || `User ${selectedUser.id}`
                  }
                </p>
                <p className="text-sm text-muted-foreground">{selectedUser.email}</p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="suspension-days">{t.suspensionDuration}</Label>
                <Select value={suspensionDays.toString()} onValueChange={(value) => setSuspensionDays(parseInt(value))}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="1">{t.oneDay}</SelectItem>
                    <SelectItem value="3">{t.threeDays}</SelectItem>
                    <SelectItem value="7">{t.sevenDays}</SelectItem>
                    <SelectItem value="14">{t.fourteenDays}</SelectItem>
                    <SelectItem value="30">{t.thirtyDays}</SelectItem>
                    <SelectItem value="90">{t.ninetyDays}</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="suspension-reason">{t.suspensionReason}</Label>
                <Input
                  id="suspension-reason"
                  placeholder={t.enterResolutionDetails}
                  value={suspensionReason}
                  onChange={(e) => setSuspensionReason(e.target.value)}
                />
              </div>
            </div>
          )}

          <DialogFooter>
            <Button variant="cancel" onClick={() => setSuspendDialogOpen(false)}>
              {t.cancel}
            </Button>
            <Button variant="suspend" onClick={confirmSuspend}>
              {t.suspendUser}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
      )}

      {/* Restore User Dialog - Only show for ADMIN */}
      {availableActions.canRestoreUsers && (
        <Dialog open={restoreDialogOpen} onOpenChange={setRestoreDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t.restoreUserAction}</DialogTitle>
            <DialogDescription>
              {t.confirmRestoreUser}
            </DialogDescription>
          </DialogHeader>

          {selectedUser && (
            <div className="py-4">
              <p className="font-medium">
                {selectedUser.firstName && selectedUser.lastName
                  ? `${selectedUser.firstName} ${selectedUser.lastName}`
                  : selectedUser.username || `User ${selectedUser.id}`
                }
              </p>
              <p className="text-sm text-muted-foreground">{selectedUser.email}</p>
            </div>
          )}

          <DialogFooter>
            <Button variant="cancel" onClick={() => setRestoreDialogOpen(false)}>
              {t.cancel}
            </Button>
            <Button 
              variant="restore"
              onClick={confirmRestore}
            >
              {t.restoreUserAction}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
      )}
    </div>
  );
}
