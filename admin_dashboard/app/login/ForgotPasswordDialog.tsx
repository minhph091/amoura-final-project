"use client";
import { useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { toast } from "@/hooks/use-toast";
import { apiClient } from "@/src/services/api.service";
import { API_ENDPOINTS } from "@/src/constants/api.constants";
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

  // Step 1: Request password reset
  const handleRequest = async () => {
    setError("");
    if (!email) {
      setError("Please enter your email.");
      return;
    }
    setLoading(true);
    try {
      const res = await apiClient.post(API_ENDPOINTS.AUTH.PASSWORD_RESET_REQUEST, { email });
      const sessionTokenResp = res.data && (res.data as any).sessionToken;
      if (res.success && sessionTokenResp) {
        setSessionToken(sessionTokenResp);
        toast({ title: "OTP sent", description: "Check your email for the OTP." });
        setStep("otp");
      } else {
        setError(res.error || "Failed to send OTP.");
      }
    } catch {
      setError("Failed to send OTP.");
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
      const res = await apiClient.post(API_ENDPOINTS.AUTH.PASSWORD_RESET_VERIFY_OTP, { sessionToken, otpCode: otp });
      const statusResp = res.data && (res.data as any).status;
      if (res.success && statusResp === "VERIFIED") {
        setStep("reset");
      } else {
        setError(res.error || "Invalid OTP or session token.");
      }
    } catch {
      setError("Failed to verify OTP.");
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
    if (!sessionToken) {
      setError("Session token missing. Please restart the reset process.");
      return;
    }
    setLoading(true);
    try {
      const res = await apiClient.post(API_ENDPOINTS.AUTH.PASSWORD_RESET, { sessionToken, newPassword });
      if (res.success) {
        toast({ title: "Password reset", description: "You can now log in with your new password." });
        onOpenChange(false);
      } else {
        setError(res.error || "Failed to reset password.");
      }
    } catch {
      setError("Failed to reset password.");
    }
    setLoading(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
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
              <Input id="forgot-email" type="email" value={email} onChange={e => setEmail(e.target.value)} autoFocus className="bg-transparent border-0 border-b-2 border-gray-300 focus:border-pink-500 text-gray-900 placeholder-gray-500 rounded-none py-3 focus:ring-0" placeholder="Enter your email" />
            </div>
          )}
          {step === "otp" && (
            <div className="space-y-2 w-full mb-4">
              <Label htmlFor="forgot-otp" className="text-gray-600 font-medium text-sm">OTP</Label>
              <Input id="forgot-otp" value={otp} onChange={e => setOtp(e.target.value)} autoFocus className="bg-transparent border-0 border-b-2 border-gray-300 focus:border-pink-500 text-gray-900 placeholder-gray-500 rounded-none py-3 focus:ring-0" placeholder="Enter OTP" />
            </div>
          )}
          {step === "reset" && (
            <div className="space-y-2 w-full mb-4">
              <Label htmlFor="forgot-new-password" className="text-gray-600 font-medium text-sm">New Password</Label>
              <Input id="forgot-new-password" type="password" value={newPassword} onChange={e => setNewPassword(e.target.value)} autoFocus className="bg-transparent border-0 border-b-2 border-gray-300 focus:border-pink-500 text-gray-900 placeholder-gray-500 rounded-none py-3 focus:ring-0" placeholder="New password" />
              <Label htmlFor="forgot-confirm-password" className="text-gray-600 font-medium text-sm">Confirm New Password</Label>
              <Input id="forgot-confirm-password" type="password" value={confirmPassword} onChange={e => setConfirmPassword(e.target.value)} className="bg-transparent border-0 border-b-2 border-gray-300 focus:border-pink-500 text-gray-900 placeholder-gray-500 rounded-none py-3 focus:ring-0" placeholder="Confirm new password" />
            </div>
          )}
          <DialogFooter className="w-full mt-2">
            {step === "email" && (
              <Button onClick={handleRequest} disabled={loading} className="w-full bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white shadow-lg font-medium py-3 rounded-full transition-all duration-300 text-lg">
                {loading ? "Sending..." : "Send OTP"}
              </Button>
            )}
            {step === "otp" && (
              <Button onClick={handleVerifyOtp} disabled={loading} className="w-full bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white shadow-lg font-medium py-3 rounded-full transition-all duration-300 text-lg">
                {loading ? "Verifying..." : "Verify OTP"}
              </Button>
            )}
            {step === "reset" && (
              <Button onClick={handleReset} disabled={loading} className="w-full bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white shadow-lg font-medium py-3 rounded-full transition-all duration-300 text-lg">
                {loading ? "Resetting..." : "Reset Password"}
              </Button>
            )}
          </DialogFooter>
        </div>
      </DialogContent>
    </Dialog>
  );
}
