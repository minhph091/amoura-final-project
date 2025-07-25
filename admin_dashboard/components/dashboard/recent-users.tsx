"use client";

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { MoreHorizontal } from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

import { useEffect, useState } from "react";
import { userService } from "@/src/services/user.service";
import type { User } from "@/src/types/user.types";

export function RecentUsers() {
  const [visibleUsers, setVisibleUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchRecentUsers = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await userService.getUsers({ page: 1, limit: 10 });
        if (!response.success)
          throw new Error(response.error || "Failed to fetch users");
        setVisibleUsers(response.data ?? []);
      } catch (err: any) {
        setError(err.message || "Unknown error");
      } finally {
        setLoading(false);
      }
    };
    fetchRecentUsers();
  }, []);

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Recent Users</CardTitle>
          <CardDescription>Latest user registrations</CardDescription>
        </CardHeader>
        <CardContent className="h-40 flex items-center justify-center">
          Loading users...
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Recent Users</CardTitle>
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
        <CardTitle>Recent Users</CardTitle>
        <CardDescription>Latest user registrations</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b bg-muted/40">
                <th className="text-left py-4 px-4 font-bold text-base">
                  User
                </th>
                <th className="text-left py-4 px-4 font-bold text-base">
                  Status
                </th>
                <th className="text-left py-4 px-4 font-bold text-base hidden md:table-cell">
                  Join Date
                </th>
                <th className="text-left py-4 px-4 font-bold text-base hidden lg:table-cell">
                  Location
                </th>
                <th className="text-right py-4 px-4 font-bold text-base">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody>
              {visibleUsers.length > 0 ? (
                visibleUsers.map((user) => (
                  <tr key={user.id} className="border-b animate-fade-in">
                    <td className="py-3 px-4">
                      <div className="flex items-center gap-3">
                        <Avatar>
                          <AvatarImage
                            src={user.avatar || "/placeholder.svg"}
                            alt={user.fullName || user.username || "User"}
                          />
                          <AvatarFallback>
                            {user.initials ||
                              (user.fullName
                                ? user.fullName[0]
                                : user.username
                                ? user.username[0]
                                : "U")}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <div className="font-medium">
                            {user.fullName || user.username || "Unknown"}
                          </div>
                          <div className="text-sm text-muted-foreground">
                            {user.email}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      <Badge
                        className={
                          user.status === "ACTIVE"
                            ? "bg-green-500 text-white"
                            : user.status === "SUSPENDED"
                            ? "bg-red-500 text-white"
                            : user.status === "PENDING"
                            ? "bg-yellow-500 text-black"
                            : user.status === "BLOCKED"
                            ? "bg-gray-500 text-white"
                            : "bg-gray-300 text-black"
                        }
                      >
                        {user.status
                          ? user.status.charAt(0) +
                            user.status.slice(1).toLowerCase()
                          : "Unknown"}
                      </Badge>
                    </td>
                    <td className="py-3 px-4 hidden md:table-cell">
                      {user.joinDate || user.createdAt || "-"}
                    </td>
                    <td className="py-3 px-4 hidden lg:table-cell">
                      {user.location || "-"}
                    </td>
                    <td className="py-3 px-4 text-right">
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button className="btn-ghost btn-icon">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem>View Profile</DropdownMenuItem>
                          <DropdownMenuItem>Edit User</DropdownMenuItem>
                          <DropdownMenuItem className="text-destructive">
                            Suspend User
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td
                    colSpan={5}
                    className="py-10 text-center text-muted-foreground"
                  >
                    No users found.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </CardContent>
    </Card>
  );
}
