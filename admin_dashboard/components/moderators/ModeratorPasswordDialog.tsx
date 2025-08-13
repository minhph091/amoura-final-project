import { useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { toast } from "@/hooks/use-toast";
import { apiClient } from "@/src/services/api.service";
import { API_ENDPOINTS } from "@/src/constants/api.constants";

export default function ModeratorPasswordDialog({ open, onOpenChange, moderatorEmail }: { open: boolean; onOpenChange: (v: boolean) => void; moderatorEmail: string }) {
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleChangePassword = async () => {
    setError("");
    if (!currentPassword || !newPassword || !confirmPassword) {
      setError("Please fill all password fields.");
      return;
    }
    if (newPassword !== confirmPassword) {
      setError("New passwords do not match.");
      return;
    }
    setLoading(true);
    try {
      const res = await apiClient.post(API_ENDPOINTS.AUTH.CHANGE_PASSWORD, {
        currentPassword,
        newPassword,
      });
      if (res.success) {
        toast({ title: "Password changed", description: "Password updated successfully." });
        setCurrentPassword("");
        setNewPassword("");
        setConfirmPassword("");
        onOpenChange(false);
      } else {
        setError(res.error || "Change password failed");
      }
    } catch {
      setError("Change password failed");
    }
    setLoading(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md w-full p-0 overflow-hidden rounded-2xl shadow-2xl">
        <div className="bg-white p-8 flex flex-col items-center">
          <DialogHeader className="w-full text-center mb-4">
            <DialogTitle className="font-heading text-2xl font-bold mb-2">
              Change Password
            </DialogTitle>
            <div className="text-gray-600 text-base mb-2">{moderatorEmail}</div>
          </DialogHeader>
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 text-sm p-3 rounded-lg w-full mb-4 text-center">
              {error}
            </div>
          )}
          <div className="space-y-2 w-full mb-4">
            <Input type="password" placeholder="Current password" value={currentPassword} onChange={e => setCurrentPassword(e.target.value)} />
            <Input type="password" placeholder="New password" value={newPassword} onChange={e => setNewPassword(e.target.value)} />
            <Input type="password" placeholder="Confirm new password" value={confirmPassword} onChange={e => setConfirmPassword(e.target.value)} />
          </div>
          <DialogFooter className="w-full mt-2">
            <Button onClick={handleChangePassword} disabled={loading} className="w-full bg-gradient-to-r from-pink-500 to-purple-600 text-white py-3 rounded-full">
              {loading ? "Changing..." : "Change Password"}
            </Button>
          </DialogFooter>
        </div>
      </DialogContent>
    </Dialog>
  );
}
