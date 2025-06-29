import React from "react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { MoreHorizontal, Eye, UserX, UserCheck } from "lucide-react";
import { STATUS_COLORS } from "@/src/constants/app.constants";
import type { User } from "@/src/types";

interface UserCardProps {
  user: User;
  onView: (user: User) => void;
  onSuspend: (user: User) => void;
  onRestore: (user: User) => void;
}

export function UserCard({
  user,
  onView,
  onSuspend,
  onRestore,
}: UserCardProps) {
  const getStatusColor = (status: string) => {
    return (
      STATUS_COLORS[status as keyof typeof STATUS_COLORS] ||
      STATUS_COLORS.inactive
    );
  };

  return (
    <div className="flex items-center justify-between p-4 border rounded-lg hover:bg-accent/50 transition-colors">
      <div className="flex items-center space-x-4">
        <Avatar className="h-12 w-12">
          <AvatarImage src={user.avatar} alt={user.name} />
          <AvatarFallback>{user.initials}</AvatarFallback>
        </Avatar>
        <div className="space-y-1">
          <div className="flex items-center space-x-2">
            <h3 className="font-medium font-heading">{user.name}</h3>
            {user.isVerified && (
              <Badge variant="secondary" className="text-xs">
                Verified
              </Badge>
            )}
          </div>
          <p className="text-sm text-muted-foreground font-primary">
            {user.email}
          </p>
          <div className="flex items-center space-x-4 text-xs text-muted-foreground font-primary">
            <span>{user.age} years old</span>
            <span>{user.location}</span>
            <span>{user.matches} matches</span>
          </div>
        </div>
      </div>

      <div className="flex items-center space-x-3">
        <Badge className={`${getStatusColor(user.status)} text-white`}>
          {user.status.charAt(0).toUpperCase() + user.status.slice(1)}
        </Badge>

        <div className="text-right text-sm">
          <p className="text-muted-foreground font-primary">Joined</p>
          <p className="font-medium font-heading">{user.joinDate}</p>
        </div>

        <div className="text-right text-sm">
          <p className="text-muted-foreground font-primary">Last Active</p>
          <p className="font-medium font-heading">{user.lastActive}</p>
        </div>

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" size="icon">
              <MoreHorizontal className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem onClick={() => onView(user)}>
              <Eye className="mr-2 h-4 w-4" />
              View Details
            </DropdownMenuItem>
            {user.status === "suspended" ? (
              <DropdownMenuItem onClick={() => onRestore(user)}>
                <UserCheck className="mr-2 h-4 w-4" />
                Restore User
              </DropdownMenuItem>
            ) : (
              <DropdownMenuItem onClick={() => onSuspend(user)}>
                <UserX className="mr-2 h-4 w-4" />
                Suspend User
              </DropdownMenuItem>
            )}
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </div>
  );
}
