"use client";
import { useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { toast } from "@/hooks/use-toast";
import { authService } from "@/src/services/auth.service";
import { AmouraLogo } from "@/components/ui/AmouraLogo";

export function ForgotPasswordDialog({ open, onOpenChange }: { open: boolean; onOpenChange: (v: boolean) => void }) {
  const [step, setStep] = useState<"email"|"otp"|"reset">("email");
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [sessionToken, setSessionToken] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const resetForm = () => {
    setStep("email");
    setEmail("");
    setOtp("");
    setSessionToken("");
    setNewPassword("");
    setConfirmPassword("");
    setError("");
  };

  // Step 1: Request password reset
  const handleRequest = async () => {
    setError("");
    if (!email) {
      setError("Please enter your email.");
      return;
    }
    setLoading(true);
    try {
      const res = await authService.requestPasswordReset({ email });
      if (res.success && res.data?.sessionToken) {
        setSessionToken(res.data.sessionToken);
        toast({ 
          title: "OTP sent", 
          description: "Check your email for the OTP code." 
        });
        setStep("otp");
      } else {
        setError(res.error || "Failed to send OTP. Please check your email and try again.");
      }
    } catch (error) {
      setError("Failed to send OTP. Please try again.");
    }
    setLoading(false);
  };

  // Step 2: Verify OTP
  const handleVerifyOtp = async () => {
    setError("");
    if (!otp) {
      setError("Please enter the OTP.");
      return;
    }
    if (!sessionToken) {
      setError("Session token missing. Please restart the reset process.");
      return;
    }
    setLoading(true);
    try {
      const res = await authService.verifyPasswordResetOtp({ sessionToken, otpCode: otp });
      if (res.success && res.data?.status === "VERIFIED") {
        setStep("reset");
      } else {
        setError(res.error || "Invalid OTP. Please check and try again.");
      }
    } catch (error) {
      setError("Failed to verify OTP. Please try again.");
    }
    setLoading(false);
  };

  // Step 3: Reset password
  const handleReset = async () => {
    setError("");
    if (!newPassword || !confirmPassword) {
      setError("Please fill all password fields.");
      return;
    }
    if (newPassword !== confirmPassword) {
      setError("Passwords do not match.");
      return;
    }
    if (newPassword.length < 8) {
      setError("Password must be at least 8 characters long.");
      return;
    }
    if (!sessionToken) {
      setError("Session token missing. Please restart the reset process.");
      return;
    }
    setLoading(true);
    try {
      const res = await authService.resetPassword({ sessionToken, newPassword });
      if (res.success) {
        toast({ 
          title: "Password reset successful", 
          description: "You can now log in with your new password." 
        });
        resetForm();
        onOpenChange(false);
      } else {
        setError(res.error || "Failed to reset password. Please try again.");
      }
    } catch (error) {
      setError("Failed to reset password. Please try again.");
    }
    setLoading(false);
  };

  const handleResendOtp = async () => {
    if (!sessionToken) {
      setError("Session token missing. Please restart the reset process.");
      return;
    }
    setLoading(true);
    try {
      const res = await authService.resendPasswordResetOtp(sessionToken);
      if (res.success) {
        toast({ 
          title: "OTP resent", 
          description: "A new OTP has been sent to your email." 
        });
      } else {
        setError(res.error || "Failed to resend OTP.");
      }
    } catch (error) {
      setError("Failed to resend OTP.");
    }
    setLoading(false);
  };

  // Reset form when dialog is closed
  const handleOpenChange = (open: boolean) => {
    if (!open) {
      resetForm();
    }
    onOpenChange(open);
  };

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogContent className="max-w-md w-full p-0 overflow-hidden rounded-2xl shadow-2xl">
        <div className="bg-white p-8 flex flex-col items-center">
          <div className="mb-6">
            <AmouraLogo size="large" />
          </div>
          <DialogHeader className="w-full text-center mb-4">
            <DialogTitle className="font-heading text-3xl font-bold bg-gradient-to-r from-pink-500 via-purple-500 to-pink-600 bg-clip-text text-transparent mb-2">
              Forgot Password
            </DialogTitle>
            <DialogDescription className="text-gray-600 text-base">
              {step === "email" && "Enter your email to receive a reset OTP."}
              {step === "otp" && "Enter the OTP sent to your email."}
              {step === "reset" && "Set your new password."}
            </DialogDescription>
          </DialogHeader>
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 text-sm p-3 rounded-lg w-full mb-4 text-center">
              {error}
            </div>
          )}
          {step === "email" && (
            <div className="space-y-2 w-full mb-4">
              <Label htmlFor="forgot-email" className="text-gray-600 font-medium text-sm">Email</Label>
              <Input 
                id="forgot-email" 
                type="email" 
                value={email} 
                onChange={e => setEmail(e.target.value)} 
                autoFocus 
                className="bg-transparent border-0 border-b-2 border-gray-300 focus:border-pink-500 text-gray-900 placeholder-gray-500 rounded-none py-3 focus:ring-0" 
                placeholder="Enter your email" 
              />
            </div>
          )}
          {step === "otp" && (
            <div className="space-y-2 w-full mb-4">
              <Label htmlFor="forgot-otp" className="text-gray-600 font-medium text-sm">OTP</Label>
              <Input 
                id="forgot-otp" 
                value={otp} 
                onChange={e => setOtp(e.target.value)} 
                autoFocus 
                className="bg-transparent border-0 border-b-2 border-gray-300 focus:border-pink-500 text-gray-900 placeholder-gray-500 rounded-none py-3 focus:ring-0" 
                placeholder="Enter 6-digit OTP" 
                maxLength={6}
              />
              <div className="flex justify-end mt-2">
                <Button 
                  type="button" 
                  variant="link" 
                  onClick={handleResendOtp} 
                  disabled={loading}
                  className="text-sm text-gray-600 hover:text-gray-800"
                >
                  Resend OTP
                </Button>
              </div>
            </div>
          )}
          {step === "reset" && (
            <div className="space-y-2 w-full mb-4">
              <Label htmlFor="forgot-new-password" className="text-gray-600 font-medium text-sm">New Password</Label>
              <Input 
                id="forgot-new-password" 
                type="password" 
                value={newPassword} 
                onChange={e => setNewPassword(e.target.value)} 
                autoFocus 
                className="bg-transparent border-0 border-b-2 border-gray-300 focus:border-pink-500 text-gray-900 placeholder-gray-500 rounded-none py-3 focus:ring-0" 
                placeholder="New password (min 8 characters)" 
              />
              <Label htmlFor="forgot-confirm-password" className="text-gray-600 font-medium text-sm">Confirm New Password</Label>
              <Input 
                id="forgot-confirm-password" 
                type="password" 
                value={confirmPassword} 
                onChange={e => setConfirmPassword(e.target.value)} 
                className="bg-transparent border-0 border-b-2 border-gray-300 focus:border-pink-500 text-gray-900 placeholder-gray-500 rounded-none py-3 focus:ring-0" 
                placeholder="Confirm new password" 
              />
            </div>
          )}
          <DialogFooter className="w-full mt-2">
            {step === "email" && (
              <Button 
                onClick={handleRequest} 
                disabled={loading} 
                className="w-full bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white shadow-lg font-medium py-3 rounded-full transition-all duration-300 text-lg"
              >
                {loading ? "Sending..." : "Send OTP"}
              </Button>
            )}
            {step === "otp" && (
              <Button 
                onClick={handleVerifyOtp} 
                disabled={loading} 
                className="w-full bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white shadow-lg font-medium py-3 rounded-full transition-all duration-300 text-lg"
              >
                {loading ? "Verifying..." : "Verify OTP"}
              </Button>
            )}
            {step === "reset" && (
              <Button 
                onClick={handleReset} 
                disabled={loading} 
                className="w-full bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white shadow-lg font-medium py-3 rounded-full transition-all duration-300 text-lg"
              >
                {loading ? "Resetting..." : "Reset Password"}
              </Button>
            )}
          </DialogFooter>
        </div>
      </DialogContent>
    </Dialog>
  );
}
