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
import { useLanguage } from "@/src/contexts/LanguageContext";
import { statsService } from "@/src/services/stats.service";
import { formatTimeAgo, getStatusColor as getStatusColorUtil, extractUserFromActivity } from "@/src/utils/dashboard.utils";

import { useEffect, useState } from "react";


export default function RecentUsers() {
  const { t } = useLanguage();
  const [visibleUsers, setVisibleUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchRecentUsers = async () => {
      setLoading(true);
      setError(null);
      try {
        const response = await statsService.getDashboard();
        // Lấy các hoạt động gần đây và chuyển đổi thành định dạng hiển thị
        const activities = response?.recentActivities || [];
        
        // Convert activities to user-friendly display format
        const userActivities = activities
          .map((activity: any, index: number) => {
            const userInfo = extractUserFromActivity(activity.description, activity.activityType);
            return {
              id: index,
              userName: userInfo.name,
              userEmail: userInfo.email,
              userPhotoUrl: null,
              userStatus: userInfo.status,
              timestamp: activity.timestamp,
              location: "Vietnam", // Default location since backend doesn't provide
              activityType: activity.activityType,
              description: activity.description
            };
          })
          .slice(0, 10);

        setVisibleUsers(userActivities);
      } catch (err: any) {
        setVisibleUsers([]);
        setError("Failed to load activities");
      } finally {
        setLoading(false);
      }
    };
    fetchRecentUsers();
  }, []);

  if (loading) return <Card><CardContent>{t.loadingText}</CardContent></Card>;
  if (error) return <Card><CardContent className="text-red-500">Error: {error}</CardContent></Card>;

  const getStatusColor = (status: string) => {
    return getStatusColorUtil(status);
  };

  const formatDate = (dateString: string) => {
    return formatTimeAgo(dateString);
  };

  const formatLocation = (location: string) => {
    if (!location) return t.unknown;
    const parts = location.split(", ");
    return parts.length > 1 ? `${parts[0]}, ${parts[parts.length - 1]}` : location;
  };

  return (
    <Card className="col-span-3">
      <CardHeader className="pb-6">
        <CardTitle className="text-xl font-semibold">{t.recentActivities}</CardTitle>
        <CardDescription>
          {t.latestSystemActivities}
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-0">
        <div className="rounded-md border">
          <div className="grid grid-cols-5 gap-4 p-4 font-medium text-muted-foreground bg-muted/50 border-b text-sm">
            <div>{t.userActivity}</div>
            <div>{t.status}</div>
            <div>{t.date}</div>
            <div>{t.location}</div>
            <div>{t.actions}</div>
          </div>
          <div className="divide-y divide-border">
            {visibleUsers.length === 0 ? (
              <div className="p-8 text-center text-muted-foreground">
                {t.noDataAvailable}
              </div>
            ) : (
              visibleUsers.map((activity: any, index: number) => (
                <div key={index} className="grid grid-cols-5 gap-4 p-4 items-center hover:bg-muted/25 transition-colors">
                  <div className="flex items-center gap-3">
                    <Avatar className="h-8 w-8">
                      <AvatarImage
                        src={activity?.userPhotoUrl || "/placeholder-user.jpg"}
                        alt={activity?.userName || "User"}
                      />
                      <AvatarFallback className="text-xs">
                        {activity?.userName
                          ? activity.userName.split(" ").map((n: string) => n[0]).join("").slice(0, 2).toUpperCase()
                          : "U"}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <div className="font-medium text-sm">
                        {activity?.userName || t.unknownUser}
                      </div>
                      <div className="text-xs text-muted-foreground">
                        {activity?.userEmail || t.unknownEmail}
                      </div>
                    </div>
                  </div>
                  <div>
                    <Badge
                      variant="outline"
                      className={`text-xs font-medium ${getStatusColor(activity?.userStatus || "active")}`}
                    >
                      {activity?.userStatus || t.active}
                    </Badge>
                  </div>
                  <div className="text-sm text-muted-foreground">
                    {formatDate(activity?.timestamp || '')}
                  </div>
                  <div className="text-sm text-muted-foreground">
                    {formatLocation(activity?.location || t.unknown)}
                  </div>
                  <div>
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" className="h-8 w-8 p-0">
                          <span className="sr-only">Open menu</span>
                          <MoreHorizontal className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuItem>{t.viewDetails}</DropdownMenuItem>
                        <DropdownMenuItem>{t.sendMessage}</DropdownMenuItem>
                        <DropdownMenuItem>{t.viewProfile}</DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </CardContent>
    </Card>
  );
}