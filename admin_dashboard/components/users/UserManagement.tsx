"use client"

import { useState, useEffect } from "react"
import type { User } from "@/src/types/user.types"
import { userService } from "@/src/services/user.service"
import { Card, CardContent } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Search, Filter, MoreHorizontal, Eye, UserX, UserCheck } from "lucide-react"





export function UserManagement() {
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState("all")
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [userDetailsOpen, setUserDetailsOpen] = useState(false)
  const [suspendDialogOpen, setSuspendDialogOpen] = useState(false)
  const [restoreDialogOpen, setRestoreDialogOpen] = useState(false)
  const [visibleUsers, setVisibleUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  // Polling for realtime updates, but pause when any dialog is open
  useEffect(() => {
    let isMounted = true;
    let interval: NodeJS.Timeout | null = null;
    async function fetchUsers() {
      setLoading(true);
      try {
        // Use real backend API for user list
        const res = await userService.getUsers();
        if (isMounted && res && res.data) {
          setVisibleUsers(res.data);
        } else if (isMounted) {
          setVisibleUsers([]);
        }
      } catch {
        if (isMounted) setVisibleUsers([]);
      }
      if (isMounted) setLoading(false);
    }

    function isAnyDialogOpen() {
      return userDetailsOpen || suspendDialogOpen || restoreDialogOpen;
    }

    function startPolling() {
      if (interval) clearInterval(interval);
      interval = setInterval(() => {
        if (!isAnyDialogOpen()) {
          fetchUsers();
        }
      }, 5000);
    }

    fetchUsers();
    startPolling();

    return () => {
      isMounted = false;
      if (interval) clearInterval(interval);
    };
  }, [userDetailsOpen, suspendDialogOpen, restoreDialogOpen]);

  const filteredUsers = visibleUsers.filter((user) => {
    const fullName = user.fullName || `${user.firstName || ''} ${user.lastName || ''}`.trim();
    const matchesSearch =
      fullName.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      String(user.id).toLowerCase().includes(searchTerm.toLowerCase());

    const matchesStatus =
      statusFilter === "all" ||
      (user.status && user.status.toLowerCase() === statusFilter.toLowerCase());

    return matchesSearch && matchesStatus;
  })

  const handleViewUser = (user: User) => {
    setSelectedUser(user)
    setUserDetailsOpen(true)
  }

  const handleSuspendUser = (user: User) => {
    setSelectedUser(user)
    setSuspendDialogOpen(true)
  }

  const handleRestoreUser = (user: User) => {
    setSelectedUser(user)
    setRestoreDialogOpen(true)
  }

  const confirmSuspend = () => {
    // In a real app, this would call an API to suspend the user
    setSuspendDialogOpen(false)
    // Refresh user list after suspend
    // (Assume fetchUsers is available in closure, or trigger a state update to force polling)
    window.dispatchEvent(new Event('users-updated'));
  }

  const confirmRestore = () => {
    // In a real app, this would call an API to restore the user
    setRestoreDialogOpen(false)
    // Refresh user list after restore
    window.dispatchEvent(new Event('users-updated'));
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row gap-4 mb-6">
            <div className="relative flex-1">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
              <Input
                type="search"
                placeholder="Search users by name, email, or ID..."
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
                  <SelectItem value="all">All Statuses</SelectItem>
                  <SelectItem value="active">Active</SelectItem>
                  <SelectItem value="suspended">Suspended</SelectItem>
                  <SelectItem value="pending">Pending</SelectItem>
                </SelectContent>
              </Select>
              <Button>Export</Button>
            </div>
          </div>

          <Tabs defaultValue="all">
            <TabsList className="mb-4">
              <TabsTrigger value="all">All Users</TabsTrigger>
              <TabsTrigger value="active">Active</TabsTrigger>
              <TabsTrigger value="suspended">Suspended</TabsTrigger>
              <TabsTrigger value="pending">Pending</TabsTrigger>
            </TabsList>

            <TabsContent value="all" className="m-0">
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="border-b bg-muted/40">
                      <th className="text-left py-4 px-4 font-bold text-base">User</th>
                      <th className="text-left py-4 px-4 font-bold text-base">Status</th>
                      <th className="text-left py-4 px-4 font-bold text-base">Created At</th>
                      <th className="text-right py-4 px-4 font-bold text-base">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {loading ? (
                      <tr>
                        <td colSpan={4} className="py-10 text-center text-muted-foreground">
                          Loading users...
                        </td>
                      </tr>
                    ) : filteredUsers.length > 0 ? (
                      filteredUsers.map((user) => (
                        <tr key={user.id} className="border-b animate-fade-in">
                          <td className="py-3 px-4">
                            <div className="flex items-center gap-3">
                              <div>
                                <div className="font-medium">{user.fullName || `${user.firstName || ''} ${user.lastName || ''}`.trim() || user.email}</div>
                                <div className="text-sm text-muted-foreground">{user.email}</div>
                              </div>
                            </div>
                          </td>
                          <td className="py-3 px-4">
                            <Badge
                              variant={
                                user.status === "ACTIVE"
                                  ? "default"
                                  : user.status === "SUSPENDED"
                                    ? "destructive"
                                    : "outline"
                              }
                              className={
                                user.status === "ACTIVE"
                                  ? "bg-green-500"
                                  : user.status === "PENDING"
                                    ? "border-yellow-500 text-yellow-500"
                                    : ""
                              }
                            >
                              {user.status ? user.status.charAt(0).toUpperCase() + user.status.slice(1).toLowerCase() : ''}
                            </Badge>
                          </td>
                          <td className="py-3 px-4">{user.createdAt}</td>
                          <td className="py-3 px-4 text-right">
                            <div className="flex justify-end gap-2">
                              <Button variant="ghost" size="icon" onClick={() => handleViewUser(user)}>
                                <Eye className="h-4 w-4" />
                              </Button>
                              {user.status !== "SUSPENDED" ? (
                                <Button
                                  variant="ghost"
                                  size="icon"
                                  className="text-destructive"
                                  onClick={() => handleSuspendUser(user)}
                                >
                                  <UserX className="h-4 w-4" />
                                </Button>
                              ) : (
                                <Button
                                  variant="ghost"
                                  size="icon"
                                  className="text-green-500"
                                  onClick={() => handleRestoreUser(user)}
                                >
                                  <UserCheck className="h-4 w-4" />
                                </Button>
                              )}
                              <DropdownMenu>
                                <DropdownMenuTrigger asChild>
                                  <Button variant="ghost" size="icon">
                                    <MoreHorizontal className="h-4 w-4" />
                                  </Button>
                                </DropdownMenuTrigger>
                                <DropdownMenuContent align="end">
                                  <DropdownMenuItem onClick={() => handleViewUser(user)}>View Profile</DropdownMenuItem>
                                  <DropdownMenuItem>Edit User</DropdownMenuItem>
                                  {user.status !== "SUSPENDED" ? (
                                    <DropdownMenuItem
                                      className="text-destructive"
                                      onClick={() => handleSuspendUser(user)}
                                    >
                                      Suspend User
                                    </DropdownMenuItem>
                                  ) : (
                                    <DropdownMenuItem
                                      className="text-green-500"
                                      onClick={() => handleRestoreUser(user)}
                                    >
                                      Restore User
                                    </DropdownMenuItem>
                                  )}
                                </DropdownMenuContent>
                              </DropdownMenu>
                            </div>
                          </td>
                        </tr>
                      ))
                    ) : (
                      <tr>
                        <td colSpan={4} className="py-10 text-center text-muted-foreground">
                          No users found matching your criteria.
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </TabsContent>

            <TabsContent value="active" className="m-0">
              {/* Similar table for active users only */}
              <div className="py-10 text-center text-muted-foreground">
                Switch to the "All Users" tab and use the status filter for a complete view.
              </div>
            </TabsContent>

            <TabsContent value="suspended" className="m-0">
              {/* Similar table for suspended users only */}
              <div className="py-10 text-center text-muted-foreground">
                Switch to the "All Users" tab and use the status filter for a complete view.
              </div>
            </TabsContent>

            <TabsContent value="pending" className="m-0">
              {/* Similar table for pending users only */}
              <div className="py-10 text-center text-muted-foreground">
                Switch to the "All Users" tab and use the status filter for a complete view.
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>

      {/* User Details Dialog */}
      <Dialog open={userDetailsOpen} onOpenChange={setUserDetailsOpen}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>User Details</DialogTitle>
            <DialogDescription>Detailed information about the selected user.</DialogDescription>
          </DialogHeader>

          {selectedUser && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 py-4">
              <div>
                <p className="text-sm font-medium">User ID</p>
                <p className="text-sm text-muted-foreground">{selectedUser.id}</p>
              </div>
              <div>
                <p className="text-sm font-medium">Username</p>
                <p className="text-sm text-muted-foreground">{selectedUser.username || ''}</p>
              </div>
              <div>
                <p className="text-sm font-medium">Email</p>
                <p className="text-sm text-muted-foreground">{selectedUser.email}</p>
              </div>
              <div>
                <p className="text-sm font-medium">Phone Number</p>
                <p className="text-sm text-muted-foreground">{selectedUser.phoneNumber || ''}</p>
              </div>
              <div>
                <p className="text-sm font-medium">First Name</p>
                <p className="text-sm text-muted-foreground">{selectedUser.firstName || ''}</p>
              </div>
              <div>
                <p className="text-sm font-medium">Last Name</p>
                <p className="text-sm text-muted-foreground">{selectedUser.lastName || ''}</p>
              </div>
              <div>
                <p className="text-sm font-medium">Full Name</p>
                <p className="text-sm text-muted-foreground">{selectedUser.fullName || ''}</p>
              </div>
              <div>
                <p className="text-sm font-medium">Role</p>
                <p className="text-sm text-muted-foreground">{selectedUser.roleName || ''}</p>
              </div>
              <div>
                <p className="text-sm font-medium">Status</p>
                <p className="text-sm text-muted-foreground">{selectedUser.status || ''}</p>
              </div>
              <div>
                <p className="text-sm font-medium">Last Login</p>
                <p className="text-sm text-muted-foreground">{selectedUser.lastLogin || ''}</p>
              </div>
              <div>
                <p className="text-sm font-medium">Created At</p>
                <p className="text-sm text-muted-foreground">{selectedUser.createdAt || ''}</p>
              </div>
              <div>
                <p className="text-sm font-medium">Updated At</p>
                <p className="text-sm text-muted-foreground">{selectedUser.updatedAt || ''}</p>
              </div>
            </div>
          )}

          <DialogFooter>
            <Button variant="outline" onClick={() => setUserDetailsOpen(false)}>
              Close
            </Button>
            {selectedUser && selectedUser.status !== "SUSPENDED" ? (
              <Button
                variant="destructive"
                onClick={() => {
                  setUserDetailsOpen(false)
                  handleSuspendUser(selectedUser)
                }}
              >
                Suspend User
              </Button>
            ) : (
              selectedUser && (
                <Button
                  variant="default"
                  onClick={() => {
                    setUserDetailsOpen(false)
                    handleRestoreUser(selectedUser)
                  }}
                >
                  Restore User
                </Button>
              )
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Suspend User Dialog */}
      <Dialog open={suspendDialogOpen} onOpenChange={setSuspendDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Suspend User</DialogTitle>
            <DialogDescription>
              Are you sure you want to suspend this user? They will not be able to access the platform until restored.
            </DialogDescription>
          </DialogHeader>


          {selectedUser && (
            <div className="py-4">
              <p className="font-medium">{selectedUser.fullName || `${selectedUser.firstName || ''} ${selectedUser.lastName || ''}`.trim() || selectedUser.email}</p>
              <p className="text-sm text-muted-foreground">{selectedUser.email}</p>
            </div>
          )}

          <DialogFooter>
            <Button variant="outline" onClick={() => setSuspendDialogOpen(false)}>
              Cancel
            </Button>
            <Button variant="destructive" onClick={confirmSuspend}>
              Suspend User
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Restore User Dialog */}
      <Dialog open={restoreDialogOpen} onOpenChange={setRestoreDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Restore User</DialogTitle>
            <DialogDescription>
              Are you sure you want to restore this user? They will regain access to the platform.
            </DialogDescription>
          </DialogHeader>

          {selectedUser && (
            <div className="py-4">
              <p className="font-medium">{selectedUser.fullName || `${selectedUser.firstName || ''} ${selectedUser.lastName || ''}`.trim() || selectedUser.email}</p>
              <p className="text-sm text-muted-foreground">{selectedUser.email}</p>
            </div>
          )}

          <DialogFooter>
            <Button variant="outline" onClick={() => setRestoreDialogOpen(false)}>
              Cancel
            </Button>
            <Button onClick={confirmRestore}>Restore User</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
