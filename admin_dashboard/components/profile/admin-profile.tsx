"use client"

import type React from "react"

import { useState, useEffect, useRef } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { toast } from "@/hooks/use-toast"
import { Badge } from "@/components/ui/badge"
import { CalendarDays, Mail, MapPin, Phone, Shield, Upload } from "lucide-react"

export function AdminProfile() {
  const [isLoading, setIsLoading] = useState(false)
  const [avatarSrc, setAvatarSrc] = useState("https://randomuser.me/api/portraits/men/44.jpg")
  const fileInputRef = useRef<HTMLInputElement>(null)

  // Load avatar from localStorage on component mount
  useEffect(() => {
    const savedAvatar = localStorage.getItem("adminAvatar")
    if (savedAvatar) {
      setAvatarSrc(savedAvatar)
    }
  }, [])

  const handleSave = () => {
    setIsLoading(true)

    // Simulate API call
    setTimeout(() => {
      setIsLoading(false)
      toast({
        title: "Profile updated",
        description: "Your profile has been updated successfully.",
      })
    }, 1000)
  }

  const handlePasswordChange = () => {
    setIsLoading(true)

    // Simulate API call
    setTimeout(() => {
      setIsLoading(false)
      toast({
        title: "Password updated",
        description: "Your password has been changed successfully.",
      })
    }, 1000)
  }

  const handleAvatarClick = () => {
    fileInputRef.current?.click()
  }

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        const result = e.target?.result as string
        setAvatarSrc(result)
        localStorage.setItem("adminAvatar", result)
      }
      reader.readAsDataURL(file)
    }
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader className="relative">
          <div className="absolute top-6 right-6">
            <Badge className="bg-primary">Super Admin</Badge>
          </div>
          <div className="flex flex-col items-center sm:flex-row sm:items-start sm:gap-6">
            <div className="relative">
              <Avatar className="h-24 w-24 cursor-pointer" onClick={handleAvatarClick}>
                <AvatarImage src={avatarSrc || "/placeholder.svg"} alt="Admin User" />
                <AvatarFallback>AD</AvatarFallback>
              </Avatar>
              <input type="file" ref={fileInputRef} className="hidden" accept="image/*" onChange={handleFileChange} />
              <Button
                size="icon"
                variant="outline"
                className="absolute -bottom-2 -right-2 h-8 w-8 rounded-full"
                onClick={handleAvatarClick}
              >
                <Upload className="h-4 w-4" />
              </Button>
            </div>
            <div className="mt-4 sm:mt-0 text-center sm:text-left">
              <CardTitle className="text-xl">Admin User</CardTitle>
              <CardDescription>Super Administrator</CardDescription>
              <div className="mt-2 flex flex-wrap gap-2 justify-center sm:justify-start">
                <div className="flex items-center text-sm text-muted-foreground">
                  <Mail className="mr-1 h-4 w-4" />
                  admin@amoura.com
                </div>
                <div className="flex items-center text-sm text-muted-foreground">
                  <Phone className="mr-1 h-4 w-4" />
                  +1 (555) 123-4567
                </div>
                <div className="flex items-center text-sm text-muted-foreground">
                  <MapPin className="mr-1 h-4 w-4" />
                  San Francisco, CA
                </div>
                <div className="flex items-center text-sm text-muted-foreground">
                  <CalendarDays className="mr-1 h-4 w-4" />
                  Joined Jan 2023
                </div>
                <div className="flex items-center text-sm text-muted-foreground">
                  <Shield className="mr-1 h-4 w-4" />
                  Full Access
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
                  <Input id="first-name" defaultValue="Admin" />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="last-name">Last Name</Label>
                  <Input id="last-name" defaultValue="User" />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input id="email" type="email" defaultValue="admin@amoura.com" />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="phone">Phone Number</Label>
                  <Input id="phone" type="tel" defaultValue="+1 (555) 123-4567" />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="job-title">Job Title</Label>
                  <Input id="job-title" defaultValue="Super Administrator" />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="department">Department</Label>
                  <Input id="department" defaultValue="Administration" />
                </div>

                <div className="space-y-2 md:col-span-2">
                  <Label htmlFor="address">Address</Label>
                  <Input id="address" defaultValue="123 Tech Street" />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="city">City</Label>
                  <Input id="city" defaultValue="San Francisco" />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="state">State/Province</Label>
                  <Input id="state" defaultValue="CA" />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="zip">Zip/Postal Code</Label>
                  <Input id="zip" defaultValue="94105" />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="country">Country</Label>
                  <Input id="country" defaultValue="United States" />
                </div>

                <div className="space-y-2 md:col-span-2">
                  <Label htmlFor="bio">Bio</Label>
                  <Textarea
                    id="bio"
                    placeholder="Tell us about yourself"
                    defaultValue="Experienced administrator with a background in dating app management and user moderation."
                    className="min-h-[100px]"
                  />
                </div>
              </div>

              <div className="flex justify-end">
                <Button onClick={handleSave} disabled={isLoading}>
                  {isLoading ? "Saving..." : "Save Changes"}
                </Button>
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

              <div className="space-y-4">
                <h3 className="text-lg font-medium">Two-Factor Authentication</h3>

                <div className="flex items-center justify-between">
                  <div>
                    <p className="font-medium">Two-factor authentication is enabled</p>
                    <p className="text-sm text-muted-foreground">
                      Your account is secured with two-factor authentication
                    </p>
                  </div>
                  <Button variant="outline">Manage</Button>
                </div>
              </div>

              <div className="space-y-4">
                <h3 className="text-lg font-medium">Login Sessions</h3>

                <div className="space-y-4">
                  <div className="flex items-center justify-between border rounded-lg p-3">
                    <div>
                      <p className="font-medium">Current Session</p>
                      <p className="text-sm text-muted-foreground">
                        San Francisco, CA • Chrome on macOS • IP: 192.168.1.1
                      </p>
                    </div>
                    <Badge>Active Now</Badge>
                  </div>

                  <div className="flex items-center justify-between border rounded-lg p-3">
                    <div>
                      <p className="font-medium">Previous Session</p>
                      <p className="text-sm text-muted-foreground">
                        San Francisco, CA • Safari on iOS • IP: 192.168.1.2
                      </p>
                    </div>
                    <Badge variant="outline">2 days ago</Badge>
                  </div>
                </div>

                <div className="flex justify-end">
                  <Button variant="outline" className="text-destructive">
                    Log Out All Other Sessions
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
                    <p className="text-sm text-muted-foreground">Today at 10:30 AM</p>
                  </div>

                  <div className="border-l-2 border-muted pl-4 pb-4">
                    <p className="font-medium">Resolved report #REP-1234</p>
                    <p className="text-sm text-muted-foreground">Yesterday at 2:15 PM</p>
                  </div>

                  <div className="border-l-2 border-muted pl-4 pb-4">
                    <p className="font-medium">Created new moderator account</p>
                    <p className="text-sm text-muted-foreground">Yesterday at 11:30 AM</p>
                  </div>

                  <div className="border-l-2 border-muted pl-4 pb-4">
                    <p className="font-medium">Updated system settings</p>
                    <p className="text-sm text-muted-foreground">2 days ago at 4:45 PM</p>
                  </div>

                  <div className="border-l-2 border-muted pl-4 pb-4">
                    <p className="font-medium">Suspended user account #U-7826</p>
                    <p className="text-sm text-muted-foreground">3 days ago at 9:20 AM</p>
                  </div>
                </div>

                <div className="flex justify-center">
                  <Button variant="outline">View Full Activity Log</Button>
                </div>
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  )
}
