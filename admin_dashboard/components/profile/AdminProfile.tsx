"use client";

import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { toast } from "@/hooks/use-toast";
import { authService } from "@/src/services/auth.service";
import type { User } from "@/src/types/user.types";
import { API_ENDPOINTS } from "@/src/constants/api.constants";
import { apiClient } from "@/src/services/api.service";

export function AdminProfile() {
  const [user, setUser] = useState<User | null>(null);
  const [edit, setEdit] = useState(false);
  // Only allow editing fields present in UpdateUserRequest
  const [form, setForm] = useState({
    username: "",
    firstName: "",
    lastName: "",
    phoneNumber: ""
  });
  const [loading, setLoading] = useState(false);
  const [pw, setPw] = useState({ current: "", new: "", confirm: "" });

  useEffect(() => {
    const u = authService.getCurrentUser();
    setUser(u);
    if (u) {
      setForm({
        username: u.username || "",
        firstName: u.firstName || "",
        lastName: u.lastName || "",
        phoneNumber: u.phoneNumber || ""
      });
    }
  }, []);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSave = async () => {
    setLoading(true);
    try {
      // Only send fields allowed by UpdateUserRequest
      const updatePayload = {
        username: form.username,
        firstName: form.firstName,
        lastName: form.lastName,
        phoneNumber: form.phoneNumber
      };
      const res = await apiClient.patch(API_ENDPOINTS.USER.PATCH, updatePayload);
      if (res.success) {
        toast({ title: "Profile updated", description: "Your profile has been updated." });
        setUser({ ...user, ...updatePayload } as User);
        setEdit(false);
      } else {
        toast({ title: "Error", description: res.error || "Update failed" });
      }
    } catch (err) {
      toast({ title: "Error", description: "Update failed" });
    }
    setLoading(false);
  };

  const handlePasswordChange = async () => {
    if (!pw.current || !pw.new || !pw.confirm) {
      toast({ title: "Error", description: "Please fill all password fields." });
      return;
    }
    if (pw.new !== pw.confirm) {
      toast({ title: "Error", description: "New passwords do not match." });
      return;
    }
    setLoading(true);
    try {
      const res = await apiClient.post(API_ENDPOINTS.AUTH.CHANGE_PASSWORD, {
        currentPassword: pw.current,
        newPassword: pw.new,
      });
      if (res.success) {
        toast({ title: "Password changed", description: "Password updated successfully." });
        setPw({ current: "", new: "", confirm: "" });
      } else {
        toast({ title: "Error", description: res.error || "Change password failed" });
      }
    } catch (err) {
      toast({ title: "Error", description: "Change password failed" });
    }
    setLoading(false);
  };

  if (!user) return <div>Loading...</div>;

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>My Profile</CardTitle>
          <Badge>{user.roleName}</Badge>
        </CardHeader>
        <CardContent>
          <form className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <Label>Email</Label>
              <Input value={user.email || ""} readOnly disabled />
            </div>
            <div>
              <Label>Username</Label>
              <Input name="username" value={form.username} onChange={handleChange} readOnly={!edit} />
            </div>
            <div>
              <Label>First Name</Label>
              <Input name="firstName" value={form.firstName} onChange={handleChange} readOnly={!edit} />
            </div>
            <div>
              <Label>Last Name</Label>
              <Input name="lastName" value={form.lastName} onChange={handleChange} readOnly={!edit} />
            </div>
            <div>
              <Label>Phone Number</Label>
              <Input name="phoneNumber" value={form.phoneNumber} onChange={handleChange} readOnly={!edit} />
            </div>
            <div>
              <Label>Status</Label>
              <Input value={user.status || ""} readOnly disabled />
            </div>
            <div>
              <Label>Role</Label>
              <Input value={user.roleName || ""} readOnly disabled />
            </div>
            <div>
              <Label>Last Login</Label>
              <Input value={user.lastLogin || ""} readOnly disabled />
            </div>
            <div>
              <Label>Created At</Label>
              <Input value={user.createdAt || ""} readOnly disabled />
            </div>
            <div>
              <Label>Updated At</Label>
              <Input value={user.updatedAt || ""} readOnly disabled />
            </div>
          </form>
          <div className="flex gap-2 mt-6">
            {!edit ? (
              <Button onClick={() => setEdit(true)} type="button">Edit</Button>
            ) : (
              <>
                <Button onClick={handleSave} type="button" disabled={loading}>Save</Button>
                <Button onClick={() => {
                  setEdit(false);
                  if (user) {
                    setForm({
                      username: user.username || "",
                      firstName: user.firstName || "",
                      lastName: user.lastName || "",
                      phoneNumber: user.phoneNumber || ""
                    });
                  }
                }} type="button" variant="outline">Cancel</Button>
              </>
            )}
          </div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader>
          <CardTitle>Change Password</CardTitle>
        </CardHeader>
        <CardContent>
          <form className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <Label>Current Password</Label>
              <Input type="password" value={pw.current} onChange={e => setPw({ ...pw, current: e.target.value })} />
            </div>
            <div>
              <Label>New Password</Label>
              <Input type="password" value={pw.new} onChange={e => setPw({ ...pw, new: e.target.value })} />
            </div>
            <div>
              <Label>Confirm New Password</Label>
              <Input type="password" value={pw.confirm} onChange={e => setPw({ ...pw, confirm: e.target.value })} />
            </div>
          </form>
          <div className="flex gap-2 mt-6">
            <Button onClick={handlePasswordChange} type="button" disabled={loading}>Change Password</Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
