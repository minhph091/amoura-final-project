"use client";

import { useState, useEffect } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Label } from "@/components/ui/label";
import { Search, Plus, MoreHorizontal, UserX, UserCheck } from "lucide-react";
import { useLanguage } from "@/src/contexts/LanguageContext";

interface Moderator {
  id: string;
  name: string;
  email: string;
  avatar: string;
  initials: string;
  status: "active" | "disabled";
  role: "moderator" | "senior moderator";
  joinDate: string;
  reportsHandled: number;
  lastActive: string;
}



export function ModeratorManagement() {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedModerator, setSelectedModerator] = useState<Moderator | null>(
    null
  );
  const [disableDialogOpen, setDisableDialogOpen] = useState(false);
  const [enableDialogOpen, setEnableDialogOpen] = useState(false);
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [visibleModerators, setVisibleModerators] = useState<Moderator[]>([]);
  const { t } = useLanguage();

  // Form state for new moderator
  const [newModeratorName, setNewModeratorName] = useState("");
  const [newModeratorEmail, setNewModeratorEmail] = useState("");
  const [newModeratorRole, setNewModeratorRole] = useState("moderator");

  useEffect(() => {
    // Feature not available: No backend endpoint for admin to fetch or manage moderators.
    setVisibleModerators([]);
  }, []);

  const filteredModerators = visibleModerators.filter((moderator) => {
    return (
      moderator.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      moderator.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      moderator.id.toLowerCase().includes(searchTerm.toLowerCase())
    );
  });

  const handleDisableModerator = (moderator: Moderator) => {
    setSelectedModerator(moderator);
    setDisableDialogOpen(true);
  };

  const handleEnableModerator = (moderator: Moderator) => {
    setSelectedModerator(moderator);
    setEnableDialogOpen(true);
  };

  const confirmDisable = () => {
    // In a real app, this would call an API to disable the moderator
    setDisableDialogOpen(false);
    // Show success message or update UI
  };

  const confirmEnable = () => {
    // In a real app, this would call an API to enable the moderator
    setEnableDialogOpen(false);
    // Show success message or update UI
  };

  const handleCreateModerator = () => {
    // In a real app, this would call an API to create a new moderator
    setCreateDialogOpen(false);
    // Reset form
    setNewModeratorName("");
    setNewModeratorEmail("");
    setNewModeratorRole("moderator");
    // Show success message or update UI
  };

  return (
    <div className="space-y-6">
      <Card>
        <CardContent className="p-6">
          <div className="flex flex-col md:flex-row gap-4 mb-6">
            <div className="relative flex-1">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
              <Input
                type="search"
                placeholder={t.searchModerators || "Search moderators..."}
                className="pl-8"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
            <Dialog open={createDialogOpen} onOpenChange={setCreateDialogOpen}>
              <DialogTrigger asChild>
                <Button className="flex items-center gap-2">
                  <Plus className="h-4 w-4" />
                  {t.addModerator || "Add Moderator"}
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Create New Moderator</DialogTitle>
                  <DialogDescription>
                    Add a new moderator to help manage the platform.
                  </DialogDescription>
                </DialogHeader>

                <div className="space-y-4 py-4">
                  <div className="space-y-2">
                    <Label htmlFor="name">Full Name</Label>
                    <Input
                      id="name"
                      placeholder="Enter full name"
                      value={newModeratorName}
                      onChange={(e) => setNewModeratorName(e.target.value)}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="email">Email</Label>
                    <Input
                      id="email"
                      type="email"
                      placeholder="Enter email address"
                      value={newModeratorEmail}
                      onChange={(e) => setNewModeratorEmail(e.target.value)}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label>Role</Label>
                    <div className="flex gap-4">
                      <div className="flex items-center">
                        <input
                          type="radio"
                          id="moderator"
                          name="role"
                          value="moderator"
                          checked={newModeratorRole === "moderator"}
                          onChange={() => setNewModeratorRole("moderator")}
                          className="mr-2"
                          title="Moderator"
                          placeholder="Moderator"
                        />
                        <Label htmlFor="moderator">Moderator</Label>
                      </div>
                      <div className="flex items-center">
                        <input
                          type="radio"
                          id="senior"
                          name="role"
                          value="senior"
                          checked={newModeratorRole === "senior moderator"}
                          onChange={() =>
                            setNewModeratorRole("senior moderator")
                          }
                          className="mr-2"
                          title="Senior Moderator"
                          placeholder="Senior Moderator"
                        />
                        <Label htmlFor="senior">Senior Moderator</Label>
                      </div>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="password">Temporary Password</Label>
                    <Input
                      id="password"
                      type="password"
                      placeholder="Enter temporary password"
                    />
                    <p className="text-xs text-muted-foreground">
                      The moderator will be prompted to change this on first
                      login.
                    </p>
                  </div>
                </div>

                <DialogFooter>
                  <Button
                    variant="outline"
                    onClick={() => setCreateDialogOpen(false)}
                  >
                    Cancel
                  </Button>
                  <Button onClick={handleCreateModerator}>
                    Create Moderator
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b bg-muted/40">
                  <th className="text-left py-4 px-4 font-bold text-base">
                    Moderator
                  </th>
                  <th className="text-left py-4 px-4 font-bold text-base">
                    Role
                  </th>
                  <th className="text-left py-4 px-4 font-bold text-base">
                    Status
                  </th>
                  <th className="text-left py-4 px-4 font-bold text-base hidden md:table-cell">
                    Join Date
                  </th>
                  <th className="text-left py-4 px-4 font-bold text-base hidden lg:table-cell">
                    Reports Handled
                  </th>
                  <th className="text-right py-4 px-4 font-bold text-base">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody>
                {filteredModerators.length > 0 ? (
                  filteredModerators.map((moderator) => (
                    <tr key={moderator.id} className="border-b animate-fade-in">
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-3">
                          <Avatar>
                            <AvatarImage
                              src={moderator.avatar || "/placeholder.svg"}
                              alt={moderator.name}
                            />
                            <AvatarFallback>
                              {moderator.initials}
                            </AvatarFallback>
                          </Avatar>
                          <div>
                            <div className="font-medium">{moderator.name}</div>
                            <div className="text-sm text-muted-foreground">
                              {moderator.email}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <Badge variant="outline" className="capitalize">
                          {moderator.role}
                        </Badge>
                      </td>
                      <td className="py-3 px-4">
                        <Badge
                          variant={
                            moderator.status === "active"
                              ? "default"
                              : "secondary"
                          }
                          className={
                            moderator.status === "active" ? "bg-green-500" : ""
                          }
                        >
                          {moderator.status.charAt(0).toUpperCase() +
                            moderator.status.slice(1)}
                        </Badge>
                      </td>
                      <td className="py-3 px-4 hidden md:table-cell">
                        {moderator.joinDate}
                      </td>
                      <td className="py-3 px-4 hidden lg:table-cell">
                        {moderator.reportsHandled}
                      </td>
                      <td className="py-3 px-4 text-right">
                        <div className="flex justify-end gap-2">
                          {moderator.status === "active" ? (
                            <Button
                              variant="ghost"
                              size="icon"
                              className="text-destructive"
                              onClick={() => handleDisableModerator(moderator)}
                            >
                              <UserX className="h-4 w-4" />
                            </Button>
                          ) : (
                            <Button
                              variant="ghost"
                              size="icon"
                              className="text-green-500"
                              onClick={() => handleEnableModerator(moderator)}
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
                              <DropdownMenuItem>View Details</DropdownMenuItem>
                              <DropdownMenuItem>
                                Edit Permissions
                              </DropdownMenuItem>
                              <DropdownMenuItem>
                                Reset Password
                              </DropdownMenuItem>
                              {moderator.status === "active" ? (
                                <DropdownMenuItem
                                  className="text-destructive"
                                  onClick={() =>
                                    handleDisableModerator(moderator)
                                  }
                                >
                                  Disable Account
                                </DropdownMenuItem>
                              ) : (
                                <DropdownMenuItem
                                  className="text-green-500"
                                  onClick={() =>
                                    handleEnableModerator(moderator)
                                  }
                                >
                                  Enable Account
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
                    <td
                      colSpan={6}
                      className="py-10 text-center text-muted-foreground"
                    >
                      {visibleModerators.length > 0
                        ? "No moderators found matching your criteria."
                        : "Loading moderators..."}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>

      {/* Disable Moderator Dialog */}
      <Dialog open={disableDialogOpen} onOpenChange={setDisableDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Disable Moderator Account</DialogTitle>
            <DialogDescription>
              Are you sure you want to disable this moderator account? They will
              no longer be able to access the admin dashboard.
            </DialogDescription>
          </DialogHeader>

          {selectedModerator && (
            <div className="flex items-center gap-4 py-4">
              <Avatar>
                <AvatarImage
                  src={selectedModerator.avatar || "/placeholder.svg"}
                  alt={selectedModerator.name}
                />
                <AvatarFallback>{selectedModerator.initials}</AvatarFallback>
              </Avatar>
              <div>
                <p className="font-medium">{selectedModerator.name}</p>
                <p className="text-sm text-muted-foreground">
                  {selectedModerator.email}
                </p>
              </div>
            </div>
          )}

          <div className="space-y-4">
            <div>
              <Label htmlFor="reason">Reason for disabling</Label>
              <Input id="reason" placeholder="Enter reason (optional)" />
            </div>
          </div>

          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setDisableDialogOpen(false)}
            >
              Cancel
            </Button>
            <Button variant="destructive" onClick={confirmDisable}>
              Disable Account
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Enable Moderator Dialog */}
      <Dialog open={enableDialogOpen} onOpenChange={setEnableDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Enable Moderator Account</DialogTitle>
            <DialogDescription>
              Are you sure you want to enable this moderator account? They will
              regain access to the admin dashboard.
            </DialogDescription>
          </DialogHeader>

          {selectedModerator && (
            <div className="flex items-center gap-4 py-4">
              <Avatar>
                <AvatarImage
                  src={selectedModerator.avatar || "/placeholder.svg"}
                  alt={selectedModerator.name}
                />
                <AvatarFallback>{selectedModerator.initials}</AvatarFallback>
              </Avatar>
              <div>
                <p className="font-medium">{selectedModerator.name}</p>
                <p className="text-sm text-muted-foreground">
                  {selectedModerator.email}
                </p>
              </div>
            </div>
          )}

          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setEnableDialogOpen(false)}
            >
              Cancel
            </Button>
            <Button onClick={confirmEnable}>Enable Account</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
