"use client";

import type React from "react";
import { profileService } from "@/src/services/profile.service";
import { apiClient } from "@/src/services/api.service";

import { useState, useEffect, useRef } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { toast } from "@/hooks/use-toast";
import { Badge } from "@/components/ui/badge";
import {
  CalendarDays,
  Mail,
  MapPin,
  Phone,
  Shield,
  Upload,
} from "lucide-react";

export function AdminProfile() {
  const [isLoading, setIsLoading] = useState(false);
  const [user, setUser] = useState<any>(null);
  const [avatarSrc, setAvatarSrc] = useState("");
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const fetchProfile = async () => {
      setIsLoading(true);
      try {
        const response = await profileService.getMyProfile();
        if (response.success && response.data) {
          setUser(response.data);
          setAvatarSrc(
            response.data.photos?.find(
              (p: { type: string; url: string }) => p.type === "AVATAR"
            )?.url || "/placeholder-user.jpg"
          );
        } else {
          toast({
            title: "Error",
            description: response.error || "Failed to fetch profile info.",
          });
        }
      } catch (err) {
        toast({ title: "Error", description: "Failed to fetch profile info." });
      } finally {
        setIsLoading(false);
      }
    };
    fetchProfile();
  }, []);

  const handleSave = async () => {
    setIsLoading(true);
    try {
      const response = await profileService.updateProfile({
        firstName: user?.firstName,
        lastName: user?.lastName,
        jobTitle: user?.jobTitle,
        bio: user?.bio,
      });
      if (response.success) {
        toast({
          title: "Profile updated",
          description: "Your profile has been updated successfully.",
        });
      } else {
        toast({
          title: "Error",
          description: response.error || "Failed to update profile.",
        });
      }
    } catch (err) {
      toast({ title: "Error", description: "Failed to update profile." });
    } finally {
      setIsLoading(false);
    }
  };

  const handlePasswordChange = async () => {
    setIsLoading(true);
    try {
      const currentPassword = (
        document.getElementById("current-password") as HTMLInputElement
      )?.value;
      const newPassword = (
        document.getElementById("new-password") as HTMLInputElement
      )?.value;
      const confirmPassword = (
        document.getElementById("confirm-password") as HTMLInputElement
      )?.value;
      if (newPassword !== confirmPassword) {
        toast({ title: "Error", description: "New passwords do not match." });
        setIsLoading(false);
        return;
      }
      // Use apiClient directly for password change (or create a service if needed)
      const response = await apiClient.post("/user/change-password", {
        currentPassword,
        newPassword,
      });
      if (response.success) {
        toast({
          title: "Password updated",
          description: "Your password has been changed successfully.",
        });
      } else {
        toast({
          title: "Error",
          description: response.error || "Failed to change password.",
        });
      }
    } catch (err) {
      toast({ title: "Error", description: "Failed to change password." });
    } finally {
      setIsLoading(false);
    }
  };

  const handleAvatarClick = () => {
    fileInputRef.current?.click();
  };

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const result = e.target?.result as string;
        setAvatarSrc(result);
        // Optionally, call backend to update avatar
      };
      reader.readAsDataURL(file);
    }
  };

  if (isLoading) {
    return <div>Loading...</div>;
  }
  if (!user) {
    return <div>No user data found.</div>;
  }
  return (
    <div className="space-y-6">
      <Card>
        <CardHeader className="relative">
          <div className="absolute top-6 right-6">
            <Badge className="bg-primary">{user.role || "Admin"}</Badge>
          </div>
          <div className="flex flex-col items-center sm:flex-row sm:items-start sm:gap-6">
            <div className="relative">
              <Avatar
                className="h-24 w-24 cursor-pointer"
                onClick={handleAvatarClick}
              >
                <AvatarImage
                  src={avatarSrc || "/placeholder-user.jpg"}
                  alt={user.firstName || "Admin User"}
                />
                <AvatarFallback>AD</AvatarFallback>
              </Avatar>
              <input
                type="file"
                ref={fileInputRef}
                className="hidden"
                accept="image/*"
                onChange={handleFileChange}
                placeholder="Upload avatar"
                title="Upload avatar"
              />
              <Button
                className="absolute -bottom-2 -right-2 h-8 w-8 rounded-full flex items-center justify-center border"
                onClick={handleAvatarClick}
              >
                <Upload className="h-4 w-4" />
              </Button>
            </div>
            <div className="mt-4 sm:mt-0 text-center sm:text-left">
              <CardTitle className="text-xl">
                {user.firstName} {user.lastName}
              </CardTitle>
              <CardDescription>
                {user.jobTitle || "Administrator"}
              </CardDescription>
              <div className="mt-2 flex flex-wrap gap-2 justify-center sm:justify-start">
                <div className="flex items-center text-sm text-muted-foreground">
                  <Mail className="mr-1 h-4 w-4" />
                  {user.email}
                </div>
                <div className="flex items-center text-sm text-muted-foreground">
                  <Phone className="mr-1 h-4 w-4" />
                  {user.phone}
                </div>
                <div className="flex items-center text-sm text-muted-foreground">
                  <MapPin className="mr-1 h-4 w-4" />
                  {user.city}, {user.state}
                </div>
                <div className="flex items-center text-sm text-muted-foreground">
                  <CalendarDays className="mr-1 h-4 w-4" />
                  Joined {user.joinedDate || "N/A"}
                </div>
                <div className="flex items-center text-sm text-muted-foreground">
                  <Shield className="mr-1 h-4 w-4" />
                  {user.accessLevel || "Full Access"}
                </div>
              </div>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <Tabs defaultValue="personal" className="mt-6">
            <TabsList className="mb-4">
              <TabsTrigger value="personal">Personal Information</TabsTrigger>
              <TabsTrigger value="security">Security</TabsTrigger>
              <TabsTrigger value="activity">Activity Log</TabsTrigger>
            </TabsList>

            <TabsContent value="personal" className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <Label htmlFor="first-name">First Name</Label>
                  <Input
                    id="first-name"
                    value={user.firstName || ""}
                    readOnly
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="last-name">Last Name</Label>
                  <Input id="last-name" value={user.lastName || ""} readOnly />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input
                    id="email"
                    type="email"
                    value={user.email || ""}
                    readOnly
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="phone">Phone Number</Label>
                  <Input
                    id="phone"
                    type="tel"
                    value={user.phone || ""}
                    readOnly
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="job-title">Job Title</Label>
                  <Input id="job-title" value={user.jobTitle || ""} readOnly />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="department">Department</Label>
                  <Input
                    id="department"
                    value={user.department || ""}
                    readOnly
                  />
                </div>
                <div className="space-y-2 md:col-span-2">
                  <Label htmlFor="address">Address</Label>
                  <Input id="address" value={user.address || ""} readOnly />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="city">City</Label>
                  <Input id="city" value={user.city || ""} readOnly />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="state">State/Province</Label>
                  <Input id="state" value={user.state || ""} readOnly />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="zip">Zip/Postal Code</Label>
                  <Input id="zip" value={user.zip || ""} readOnly />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="country">Country</Label>
                  <Input id="country" value={user.country || ""} readOnly />
                </div>
                <div className="space-y-2 md:col-span-2">
                  <Label htmlFor="bio">Bio</Label>
                  <Textarea
                    id="bio"
                    value={user.bio || ""}
                    readOnly
                    className="min-h-[100px]"
                  />
                </div>
              </div>
            </TabsContent>

            <TabsContent value="security" className="space-y-6">
              <div className="space-y-4">
                <h3 className="text-lg font-medium">Change Password</h3>
                <div className="space-y-2">
                  <Label htmlFor="current-password">Current Password</Label>
                  <Input id="current-password" type="password" />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="new-password">New Password</Label>
                  <Input id="new-password" type="password" />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="confirm-password">Confirm New Password</Label>
                  <Input id="confirm-password" type="password" />
                </div>
                <div className="flex justify-end">
                  <Button onClick={handlePasswordChange} disabled={isLoading}>
                    {isLoading ? "Updating..." : "Change Password"}
                  </Button>
                </div>
              </div>
            </TabsContent>

            <TabsContent value="activity" className="space-y-6">
              <div className="space-y-4">
                <h3 className="text-lg font-medium">Recent Activity</h3>
                <div className="space-y-4">
                  <div className="border-l-2 border-primary pl-4 pb-4">
                    <p className="font-medium">Updated user settings</p>
                    <p className="text-sm text-muted-foreground">
                      Today at 10:30 AM
                    </p>
                  </div>
                </div>
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  );
}
