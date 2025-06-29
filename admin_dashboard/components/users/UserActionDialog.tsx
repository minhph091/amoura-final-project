import React from "react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import type { User } from "@/src/types";

interface UserActionDialogProps {
  user: User | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  action: "suspend" | "restore";
  onConfirm: (reason?: string) => void;
  loading?: boolean;
}

export function UserActionDialog({
  user,
  open,
  onOpenChange,
  action,
  onConfirm,
  loading = false,
}: UserActionDialogProps) {
  const [reason, setReason] = React.useState("");

  const handleConfirm = () => {
    onConfirm(action === "suspend" ? reason : undefined);
    setReason("");
  };

  const handleCancel = () => {
    onOpenChange(false);
    setReason("");
  };

  if (!user) return null;

  const isSuspend = action === "suspend";
  const title = isSuspend ? "Suspend User" : "Restore User";
  const description = isSuspend
    ? `Are you sure you want to suspend ${user.name}? This will prevent them from accessing the platform.`
    : `Are you sure you want to restore ${user.name}? This will allow them to access the platform again.`;

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          <DialogDescription>{description}</DialogDescription>
        </DialogHeader>

        {isSuspend && (
          <div className="space-y-2">
            <Label htmlFor="reason">Reason for suspension (optional)</Label>
            <Textarea
              id="reason"
              placeholder="Enter the reason for suspending this user..."
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              rows={3}
            />
          </div>
        )}

        <DialogFooter>
          <Button variant="outline" onClick={handleCancel} disabled={loading}>
            Cancel
          </Button>
          <Button
            variant={isSuspend ? "destructive" : "default"}
            onClick={handleConfirm}
            disabled={loading}
          >
            {loading
              ? "Processing..."
              : isSuspend
              ? "Suspend User"
              : "Restore User"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
