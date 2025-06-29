"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Switch } from "@/components/ui/switch"
import { toast } from "@/hooks/use-toast"

export function SettingsNotifications() {
  const [isLoading, setIsLoading] = useState(false)

  const handleSave = () => {
    setIsLoading(true)

    // Simulate API call
    setTimeout(() => {
      setIsLoading(false)
      toast({
        title: "Notification settings updated",
        description: "Your notification preferences have been updated successfully.",
      })
    }, 1000)
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Notification Settings</CardTitle>
        <CardDescription>Configure which notifications you receive and how they are delivered</CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="space-y-4">
          <h3 className="text-lg font-medium">Email Notifications</h3>

          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="new-users">New User Registrations</Label>
                <p className="text-sm text-muted-foreground">Receive an email when new users register</p>
              </div>
              <Switch id="new-users" defaultChecked />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="reports">User Reports</Label>
                <p className="text-sm text-muted-foreground">Receive an email when a user submits a report</p>
              </div>
              <Switch id="reports" defaultChecked />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="premium">Premium Subscriptions</Label>
                <p className="text-sm text-muted-foreground">
                  Receive an email when a user purchases a premium subscription
                </p>
              </div>
              <Switch id="premium" defaultChecked />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="system-alerts">System Alerts</Label>
                <p className="text-sm text-muted-foreground">
                  Receive an email for important system alerts and warnings
                </p>
              </div>
              <Switch id="system-alerts" defaultChecked />
            </div>
          </div>
        </div>

        <div className="space-y-4">
          <h3 className="text-lg font-medium">Dashboard Notifications</h3>

          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="dashboard-new-users">New User Registrations</Label>
                <p className="text-sm text-muted-foreground">Show notifications for new user registrations</p>
              </div>
              <Switch id="dashboard-new-users" defaultChecked />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="dashboard-reports">User Reports</Label>
                <p className="text-sm text-muted-foreground">Show notifications for new user reports</p>
              </div>
              <Switch id="dashboard-reports" defaultChecked />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="dashboard-premium">Premium Subscriptions</Label>
                <p className="text-sm text-muted-foreground">Show notifications for new premium subscriptions</p>
              </div>
              <Switch id="dashboard-premium" defaultChecked />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="dashboard-system">System Alerts</Label>
                <p className="text-sm text-muted-foreground">Show notifications for system alerts and warnings</p>
              </div>
              <Switch id="dashboard-system" defaultChecked />
            </div>
          </div>
        </div>

        <div className="space-y-4">
          <h3 className="text-lg font-medium">Notification Digest</h3>

          <div className="flex items-center justify-between">
            <div>
              <Label htmlFor="daily-digest">Daily Digest</Label>
              <p className="text-sm text-muted-foreground">Receive a daily summary of all notifications</p>
            </div>
            <Switch id="daily-digest" />
          </div>

          <div className="flex items-center justify-between">
            <div>
              <Label htmlFor="weekly-digest">Weekly Digest</Label>
              <p className="text-sm text-muted-foreground">Receive a weekly summary of all notifications</p>
            </div>
            <Switch id="weekly-digest" defaultChecked />
          </div>
        </div>
      </CardContent>
      <CardFooter className="flex justify-between">
        <Button variant="outline">Reset to Defaults</Button>
        <Button onClick={handleSave} disabled={isLoading}>
          {isLoading ? "Saving..." : "Save Changes"}
        </Button>
      </CardFooter>
    </Card>
  )
}
