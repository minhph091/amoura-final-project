"use client";

import type { Metadata } from "next"
import { SettingsGeneral } from "@/components/settings/SettingsGeneral"
import { SettingsSecurity } from "@/components/settings/SettingsSecurity"
import { SettingsNotifications } from "@/components/settings/SettingsNotifications"
import { SettingsAppearance } from "@/components/settings/SettingsAppearance"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { useLanguage } from "@/src/contexts/LanguageContext"

export default function SettingsPage() {
  const { t } = useLanguage();

  return (
    <div className="space-y-6 animate-fade-in">
      <div className="flex items-center space-x-4">
        <h1 className="text-4xl font-bold bg-gradient-to-r from-purple-500 via-pink-500 to-red-500 bg-clip-text text-transparent">
          {t.settingsTitle}
        </h1>
        <div className="h-8 w-1 bg-gradient-to-b from-purple-500 to-red-500 rounded-full"></div>
      </div>

      <Tabs defaultValue="general" className="space-y-4">
        <TabsList>
          <TabsTrigger value="general">{t.general}</TabsTrigger>
          <TabsTrigger value="security">{t.security}</TabsTrigger>
          <TabsTrigger value="notifications">{t.notifications}</TabsTrigger>
          <TabsTrigger value="appearance">{t.appearance}</TabsTrigger>
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
