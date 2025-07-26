import type { Metadata } from "next"
import { SettingsGeneral } from "@/components/settings/SettingsGeneral"
import { SettingsSecurity } from "@/components/settings/SettingsSecurity"
import { SettingsNotifications } from "@/components/settings/SettingsNotifications"
import { SettingsAppearance } from "@/components/settings/SettingsAppearance"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

export const metadata: Metadata = {
  title: "Settings | Amoura Admin",
  description: "Admin settings for Amoura dating application",
}

export default function SettingsPage() {
  return (
    <div className="space-y-6 animate-fade-in">
      <h1 className="text-3xl font-bold tracking-tight">Settings</h1>

      <Tabs defaultValue="general" className="space-y-4">
        <TabsList>
          <TabsTrigger value="general">General</TabsTrigger>
          <TabsTrigger value="security">Security</TabsTrigger>
          <TabsTrigger value="notifications">Notifications</TabsTrigger>
          <TabsTrigger value="appearance">Appearance</TabsTrigger>
        </TabsList>

        <TabsContent value="general" className="space-y-4">
          <SettingsGeneral />
        </TabsContent>

        <TabsContent value="security" className="space-y-4">
          <SettingsSecurity />
        </TabsContent>

        <TabsContent value="notifications" className="space-y-4">
          <SettingsNotifications />
        </TabsContent>

        <TabsContent value="appearance" className="space-y-4">
          <SettingsAppearance />
        </TabsContent>
      </Tabs>
    </div>
  )
}
