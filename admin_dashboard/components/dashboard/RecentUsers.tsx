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

import { statsService } from "@/src/services/stats.service";


export default function RecentUsers() {
  const [visibleUsers, setVisibleUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchRecentUsers = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await statsService.getDashboard();
        // Lấy các hoạt động đăng ký user gần đây
        const activities = response.recentActivities || [];
        // Lọc các hoạt động đăng ký user
        const recentUserActivities = activities.filter((a: any) => a.activityType === "USER_REGISTRATION");
        setVisibleUsers(recentUserActivities.slice(0, 10));
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
                visibleUsers.map((activity) => (
                  <tr key={activity.userId + activity.timestamp} className="border-b animate-fade-in">
                    <td className="py-3 px-4">
                      <div className="flex items-center gap-3">
                        <Avatar>
                          <AvatarImage
                            src={"/placeholder.svg"}
                            alt={activity.username || "User"}
                          />
                          <AvatarFallback>
                            {activity.username ? activity.username[0] : "U"}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <div className="font-medium">
                            {activity.username || "Unknown"}
                          </div>
                          <div className="text-sm text-muted-foreground">
                            User ID: {activity.userId ?? "-"}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="py-3 px-4">
                      <Badge className="bg-green-500 text-white">New</Badge>
                    </td>
                    <td className="py-3 px-4 hidden md:table-cell">
                      {activity.timestamp ? new Date(activity.timestamp).toLocaleString() : "-"}
                    </td>
                    <td className="py-3 px-4 hidden lg:table-cell">-</td>
                    <td className="py-3 px-4 text-right">
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button className="btn-ghost btn-icon">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem>View Profile</DropdownMenuItem>
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
