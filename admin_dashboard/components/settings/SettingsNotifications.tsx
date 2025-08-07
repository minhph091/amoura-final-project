"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Switch } from "@/components/ui/switch"
import { toast } from "@/hooks/use-toast"
import { useLanguage } from "@/src/contexts/LanguageContext"

export function SettingsNotifications() {
  const { t } = useLanguage();
  const [isLoading, setIsLoading] = useState(false)

  const handleSave = () => {
    setIsLoading(true)

    // Feature not available: No backend endpoint for admin to manage notification settings.
    setTimeout(() => {
      setIsLoading(false)
      toast({
        title: t.settingsUpdatedTitle,
        description: t.notificationSettingsUpdated,
      })
    }, 1000)
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>{t.notificationSettingsTitle}</CardTitle>
        <CardDescription>{t.notificationSettingsDescription}</CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="space-y-4">
          <h3 className="text-lg font-medium">{t.emailNotifications}</h3>

          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="new-users">{t.newUserRegistrations}</Label>
                <p className="text-sm text-muted-foreground">{t.receiveEmailNewUsers}</p>
              </div>
              <Switch id="new-users" defaultChecked />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="reports">{t.userReports}</Label>
                <p className="text-sm text-muted-foreground">{t.receiveEmailUserReports}</p>
              </div>
              <Switch id="reports" defaultChecked />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="premium">{t.premiumSubscriptions}</Label>
                <p className="text-sm text-muted-foreground">
                  {t.receiveEmailPremiumSubscriptions}
                </p>
              </div>
              <Switch id="premium" defaultChecked />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="system-alerts">{t.systemAlerts}</Label>
                <p className="text-sm text-muted-foreground">
                  {t.receiveEmailSystemAlerts}
                </p>
              </div>
              <Switch id="system-alerts" defaultChecked />
            </div>
          </div>
        </div>

        <div className="space-y-4">
          <h3 className="text-lg font-medium">{t.dashboardNotifications}</h3>

          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="dashboard-new-users">{t.newUserRegistrations}</Label>
                <p className="text-sm text-muted-foreground">{t.showNotificationsNewUsers}</p>
              </div>
              <Switch id="dashboard-new-users" defaultChecked />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="dashboard-reports">{t.userReports}</Label>
                <p className="text-sm text-muted-foreground">{t.showNotificationsUserReports}</p>
              </div>
              <Switch id="dashboard-reports" defaultChecked />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="dashboard-premium">{t.premiumSubscriptions}</Label>
                <p className="text-sm text-muted-foreground">{t.showNotificationsPremiumSubscriptions}</p>
              </div>
              <Switch id="dashboard-premium" defaultChecked />
            </div>

            <div className="flex items-center justify-between">
              <div>
                <Label htmlFor="dashboard-system">{t.systemAlerts}</Label>
                <p className="text-sm text-muted-foreground">{t.showNotificationsSystemAlerts}</p>
              </div>
              <Switch id="dashboard-system" defaultChecked />
            </div>
          </div>
        </div>

        <div className="space-y-4">
          <h3 className="text-lg font-medium">{t.notificationDigest}</h3>

          <div className="flex items-center justify-between">
            <div>
              <Label htmlFor="daily-digest">{t.dailyDigest}</Label>
              <p className="text-sm text-muted-foreground">{t.receiveDailySummary}</p>
            </div>
            <Switch id="daily-digest" />
          </div>

          <div className="flex items-center justify-between">
            <div>
              <Label htmlFor="weekly-digest">{t.weeklyDigest}</Label>
              <p className="text-sm text-muted-foreground">{t.receiveWeeklySummary}</p>
            </div>
            <Switch id="weekly-digest" defaultChecked />
          </div>
        </div>
      </CardContent>
      <CardFooter className="flex justify-between">
        <Button variant="cancel">{t.resetToDefaults}</Button>
        <Button variant="save" onClick={handleSave} disabled={isLoading}>
          {isLoading ? t.saving : t.saveChanges}
        </Button>
      </CardFooter>
    </Card>
  )
}
