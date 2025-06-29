import React from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { CalendarDays, Mail, MapPin, Heart, Flag } from "lucide-react";
import { STATUS_COLORS } from "@/src/constants/app.constants";
import type { User } from "@/src/types";

interface UserDetailsDialogProps {
  user: User | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function UserDetailsDialog({
  user,
  open,
  onOpenChange,
}: UserDetailsDialogProps) {
  if (!user) return null;

  const getStatusColor = (status: string) => {
    return (
      STATUS_COLORS[status as keyof typeof STATUS_COLORS] ||
      STATUS_COLORS.inactive
    );
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>User Details</DialogTitle>
          <DialogDescription>
            View detailed information about this user
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6">
          {/* User Header */}
          <div className="flex items-center space-x-4">
            <Avatar className="h-20 w-20">
              <AvatarImage src={user.avatar} alt={user.name} />
              <AvatarFallback className="text-lg">
                {user.initials}
              </AvatarFallback>
            </Avatar>
            <div className="space-y-2">
              <div className="flex items-center space-x-2">
                <h2 className="text-2xl font-bold">{user.name}</h2>
                {user.isVerified && <Badge variant="secondary">Verified</Badge>}
              </div>
              <Badge className={`${getStatusColor(user.status)} text-white`}>
                {user.status.charAt(0).toUpperCase() + user.status.slice(1)}
              </Badge>
            </div>
          </div>

          <Tabs defaultValue="profile" className="w-full">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="profile">Profile</TabsTrigger>
              <TabsTrigger value="activity">Activity</TabsTrigger>
              <TabsTrigger value="reports">Reports</TabsTrigger>
            </TabsList>

            <TabsContent value="profile" className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <div className="flex items-center space-x-2 text-sm">
                    <Mail className="h-4 w-4 text-muted-foreground" />
                    <span className="text-muted-foreground">Email:</span>
                    <span>{user.email}</span>
                  </div>
                  <div className="flex items-center space-x-2 text-sm">
                    <CalendarDays className="h-4 w-4 text-muted-foreground" />
                    <span className="text-muted-foreground">Age:</span>
                    <span>{user.age} years old</span>
                  </div>
                  <div className="flex items-center space-x-2 text-sm">
                    <MapPin className="h-4 w-4 text-muted-foreground" />
                    <span className="text-muted-foreground">Location:</span>
                    <span>{user.location}</span>
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="flex items-center space-x-2 text-sm">
                    <CalendarDays className="h-4 w-4 text-muted-foreground" />
                    <span className="text-muted-foreground">Joined:</span>
                    <span>{user.joinDate}</span>
                  </div>
                  <div className="flex items-center space-x-2 text-sm">
                    <Heart className="h-4 w-4 text-muted-foreground" />
                    <span className="text-muted-foreground">Matches:</span>
                    <span>{user.matches}</span>
                  </div>
                  <div className="flex items-center space-x-2 text-sm">
                    <Flag className="h-4 w-4 text-muted-foreground" />
                    <span className="text-muted-foreground">Reports:</span>
                    <span>{user.reports}</span>
                  </div>
                </div>
              </div>

              {user.bio && (
                <div className="space-y-2">
                  <h4 className="font-medium">Bio</h4>
                  <p className="text-sm text-muted-foreground">{user.bio}</p>
                </div>
              )}
            </TabsContent>

            <TabsContent value="activity" className="space-y-4">
              <div className="space-y-2">
                <h4 className="font-medium">Recent Activity</h4>
                <div className="text-sm text-muted-foreground">
                  <p>Last active: {user.lastActive}</p>
                  <p>Total matches: {user.matches}</p>
                  <p>Account status: {user.status}</p>
                </div>
              </div>
            </TabsContent>

            <TabsContent value="reports" className="space-y-4">
              <div className="space-y-2">
                <h4 className="font-medium">Reports ({user.reports})</h4>
                {user.reports === 0 ? (
                  <p className="text-sm text-muted-foreground">
                    No reports filed against this user.
                  </p>
                ) : (
                  <p className="text-sm text-muted-foreground">
                    This user has {user.reports} report(s) filed against them.
                  </p>
                )}
              </div>
            </TabsContent>
          </Tabs>
        </div>
      </DialogContent>
    </Dialog>
  );
}
