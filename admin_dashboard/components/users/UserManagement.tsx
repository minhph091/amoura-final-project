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
  useEffect(() => {
    async function fetchUsers() {
      setLoading(true)
      try {
        const res = await userService.getUsers()
        if (res && Array.isArray(res.data)) {
          setVisibleUsers(res.data)
        } else {
          setVisibleUsers([])
        }
      } catch {
        setVisibleUsers([])
      }
      setLoading(false)
    }
    fetchUsers()
  }, [])

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
    // Show success message or update UI
  }

  const confirmRestore = () => {
    // In a real app, this would call an API to restore the user
    setRestoreDialogOpen(false)
    // Show success message or update UI
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
                      <th className="text-left py-4 px-4 font-bold text-base hidden md:table-cell">Join Date</th>
                      <th className="text-left py-4 px-4 font-bold text-base hidden lg:table-cell">Location</th>
                      <th className="text-right py-4 px-4 font-bold text-base">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {loading ? (
                      <tr>
                        <td colSpan={5} className="py-10 text-center text-muted-foreground">
                          Loading users...
                        </td>
                      </tr>
                    ) : filteredUsers.length > 0 ? (
                      filteredUsers.map((user) => (
                        <tr key={user.id} className="border-b animate-fade-in">
                          <td className="py-3 px-4">
                            <div className="flex items-center gap-3">
                              <Avatar>
                                {user.avatar ? (
                                  <AvatarImage src={user.avatar} alt={user.fullName || user.email} />
                                ) : (
                                  <AvatarFallback>{user.fullName?.[0] || user.email?.[0] || ''}</AvatarFallback>
                                )}
                              </Avatar>
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
                          <td className="py-3 px-4 hidden md:table-cell">{user.joinDate || user.createdAt}</td>
                          <td className="py-3 px-4 hidden lg:table-cell">{user.location || ''}</td>
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
                        <td colSpan={5} className="py-10 text-center text-muted-foreground">
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
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 py-4">
              <div className="md:col-span-1 flex flex-col items-center">
                <Avatar className="h-24 w-24 mb-4">
                  {selectedUser.avatar ? (
                    <AvatarImage src={selectedUser.avatar} alt={selectedUser.fullName || selectedUser.email} />
                  ) : (
                    <AvatarFallback>{selectedUser.fullName?.[0] || selectedUser.email?.[0] || ''}</AvatarFallback>
                  )}
                </Avatar>
                <h3 className="text-lg font-semibold">{selectedUser.fullName || `${selectedUser.firstName || ''} ${selectedUser.lastName || ''}`.trim() || selectedUser.email}</h3>
                <p className="text-sm text-muted-foreground mb-2">{selectedUser.email}</p>
                <Badge
                  variant={
                    selectedUser.status === "ACTIVE"
                      ? "default"
                      : selectedUser.status === "SUSPENDED"
                        ? "destructive"
                        : "outline"
                  }
                  className={
                    selectedUser.status === "ACTIVE"
                      ? "bg-green-500"
                      : selectedUser.status === "PENDING"
                        ? "border-yellow-500 text-yellow-500"
                        : ""
                  }
                >
                  {selectedUser.status ? selectedUser.status.charAt(0).toUpperCase() + selectedUser.status.slice(1).toLowerCase() : ''}
                </Badge>
              </div>

              <div className="md:col-span-2">
                <Tabs defaultValue="info">
                  <TabsList className="mb-4">
                    <TabsTrigger value="info">Basic Info</TabsTrigger>
                    <TabsTrigger value="activity">Activity</TabsTrigger>
                    <TabsTrigger value="reports">Reports</TabsTrigger>
                  </TabsList>

                  <TabsContent value="info" className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <p className="text-sm font-medium">User ID</p>
                        <p className="text-sm text-muted-foreground">{selectedUser.id}</p>
                      </div>
                      <div>
                        <p className="text-sm font-medium">Join Date</p>
                        <p className="text-sm text-muted-foreground">{selectedUser.joinDate || selectedUser.createdAt}</p>
                      </div>
                      <div>
                        <p className="text-sm font-medium">Age</p>
                        <p className="text-sm text-muted-foreground">{selectedUser.age || ''}</p>
                      </div>
                      <div>
                        <p className="text-sm font-medium">Gender</p>
                        <p className="text-sm text-muted-foreground">{selectedUser.gender || ''}</p>
                      </div>
                      <div>
                        <p className="text-sm font-medium">Location</p>
                        <p className="text-sm text-muted-foreground">{selectedUser.location || ''}</p>
                      </div>
                      <div>
                        <p className="text-sm font-medium">Last Active</p>
                        <p className="text-sm text-muted-foreground">{selectedUser.lastActive || ''}</p>
                      </div>
                    </div>
                  </TabsContent>

                  <TabsContent value="activity">
                    <div className="space-y-4">
                      <div>
                        <p className="text-sm font-medium">Total Matches</p>
                        <p className="text-sm text-muted-foreground">{selectedUser.matches || ''}</p>
                      </div>
                      <div>
                        <p className="text-sm font-medium">Last Login</p>
                        <p className="text-sm text-muted-foreground">{selectedUser.lastActive || ''}</p>
                      </div>
                      <div>
                        <p className="text-sm font-medium">Account Status</p>
                        <Badge
                          variant={
                            selectedUser.status === "ACTIVE"
                              ? "default"
                              : selectedUser.status === "SUSPENDED"
                                ? "destructive"
                                : "outline"
                          }
                          className={
                            selectedUser.status === "ACTIVE"
                              ? "bg-green-500"
                              : selectedUser.status === "PENDING"
                                ? "border-yellow-500 text-yellow-500"
                                : ""
                          }
                        >
                          {selectedUser.status ? selectedUser.status.charAt(0).toUpperCase() + selectedUser.status.slice(1).toLowerCase() : ''}
                        </Badge>
                      </div>
                    </div>
                  </TabsContent>

                  <TabsContent value="reports">
                    {selectedUser.reports && selectedUser.reports > 0 ? (
                      <div className="space-y-4">
                        <p>This user has {selectedUser.reports} reports against them.</p>
                        {/* List of reports would go here */}
                      </div>
                    ) : (
                      <p>This user has no reports against them.</p>
                    )}
                  </TabsContent>
                </Tabs>
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
            <div className="flex items-center gap-4 py-4">
              <Avatar>
                {selectedUser.avatar ? (
                  <AvatarImage src={selectedUser.avatar} alt={selectedUser.fullName || `${selectedUser.firstName || ''} ${selectedUser.lastName || ''}`.trim() || selectedUser.email} />
                ) : (
                  <AvatarFallback>{selectedUser.initials || selectedUser.fullName?.[0] || selectedUser.email?.[0] || ''}</AvatarFallback>
                )}
              </Avatar>
              <div>
                <p className="font-medium">{selectedUser.fullName || `${selectedUser.firstName || ''} ${selectedUser.lastName || ''}`.trim() || selectedUser.email}</p>
                <p className="text-sm text-muted-foreground">{selectedUser.email}</p>
              </div>
            </div>
          )}

          <div className="space-y-4">
            <div>
              <label htmlFor="reason" className="text-sm font-medium">
                Suspension Reason
              </label>
              <Select defaultValue="inappropriate">
                <SelectTrigger id="reason">
                  <SelectValue placeholder="Select a reason" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="inappropriate">Inappropriate Content</SelectItem>
                  <SelectItem value="harassment">Harassment</SelectItem>
                  <SelectItem value="fake">Fake Profile</SelectItem>
                  <SelectItem value="spam">Spam</SelectItem>
                  <SelectItem value="other">Other</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div>
              <label htmlFor="duration" className="text-sm font-medium">
                Suspension Duration
              </label>
              <Select defaultValue="7">
                <SelectTrigger id="duration">
                  <SelectValue placeholder="Select duration" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="1">1 Day</SelectItem>
                  <SelectItem value="3">3 Days</SelectItem>
                  <SelectItem value="7">7 Days</SelectItem>
                  <SelectItem value="30">30 Days</SelectItem>
                  <SelectItem value="permanent">Permanent</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

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
            <div className="flex items-center gap-4 py-4">
              <Avatar>
                {selectedUser.avatar ? (
                  <AvatarImage src={selectedUser.avatar} alt={selectedUser.fullName || `${selectedUser.firstName || ''} ${selectedUser.lastName || ''}`.trim() || selectedUser.email} />
                ) : (
                  <AvatarFallback>{selectedUser.initials || selectedUser.fullName?.[0] || selectedUser.email?.[0] || ''}</AvatarFallback>
                )}
              </Avatar>
              <div>
                <p className="font-medium">{selectedUser.fullName || `${selectedUser.firstName || ''} ${selectedUser.lastName || ''}`.trim() || selectedUser.email}</p>
                <p className="text-sm text-muted-foreground">{selectedUser.email}</p>
              </div>
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
