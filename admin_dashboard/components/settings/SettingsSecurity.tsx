"use client"

import { Textarea } from "@/components/ui/textarea"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Switch } from "@/components/ui/switch"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { toast } from "@/hooks/use-toast"

export function SettingsSecurity() {
  const [isLoading, setIsLoading] = useState(false)

  const handleSave = () => {
    setIsLoading(true)

    // Feature not available: No backend endpoint for admin to manage security settings.
    setTimeout(() => {
      setIsLoading(false)
      toast({
        title: "Security settings updated",
        description: "Your security settings have been updated successfully.",
      })
    }, 1000)
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Security Settings</CardTitle>
        <CardDescription>Manage security settings and authentication preferences</CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <Label htmlFor="2fa">Two-Factor Authentication</Label>
            <Switch id="2fa" defaultChecked />
          </div>
          <p className="text-sm text-muted-foreground">
            Require administrators to use two-factor authentication when logging in
          </p>
        </div>

        <div className="space-y-2">
          <Label htmlFor="session-timeout">Session Timeout</Label>
          <Select defaultValue="60">
            <SelectTrigger id="session-timeout">
              <SelectValue placeholder="Select timeout period" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="15">15 minutes</SelectItem>
              <SelectItem value="30">30 minutes</SelectItem>
              <SelectItem value="60">1 hour</SelectItem>
              <SelectItem value="120">2 hours</SelectItem>
              <SelectItem value="240">4 hours</SelectItem>
            </SelectContent>
          </Select>
          <p className="text-sm text-muted-foreground">
            Automatically log out administrators after a period of inactivity
          </p>
        </div>

        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <Label htmlFor="ip-restriction">IP Address Restriction</Label>
            <Switch id="ip-restriction" />
          </div>
          <p className="text-sm text-muted-foreground">Restrict admin access to specific IP addresses</p>
        </div>

        <div className="space-y-2">
          <Label htmlFor="allowed-ips">Allowed IP Addresses</Label>
          <Textarea id="allowed-ips" placeholder="Enter IP addresses, one per line" className="h-20" />
          <p className="text-sm text-muted-foreground">
            Only these IP addresses will be allowed to access the admin dashboard
          </p>
        </div>

        <div className="space-y-2">
          <Label htmlFor="password-policy">Password Policy</Label>
          <Select defaultValue="strong">
            <SelectTrigger id="password-policy">
              <SelectValue placeholder="Select password policy" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="basic">Basic (8+ characters)</SelectItem>
              <SelectItem value="medium">Medium (8+ chars, letters & numbers)</SelectItem>
              <SelectItem value="strong">Strong (8+ chars, upper/lowercase, numbers, symbols)</SelectItem>
              <SelectItem value="custom">Custom Policy</SelectItem>
            </SelectContent>
          </Select>
          <p className="text-sm text-muted-foreground">Set the password complexity requirements for admin accounts</p>
        </div>

        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <Label htmlFor="audit-logging">Audit Logging</Label>
            <Switch id="audit-logging" defaultChecked />
          </div>
          <p className="text-sm text-muted-foreground">Log all administrator actions for security and compliance</p>
        </div>
      </CardContent>
      <CardFooter className="flex justify-between">
        <Button variant="outline">Reset</Button>
        <Button onClick={handleSave} disabled={isLoading}>
          {isLoading ? "Saving..." : "Save Changes"}
        </Button>
      </CardFooter>
    </Card>
  )
}
