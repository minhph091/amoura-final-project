"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { useTheme } from "next-themes"
import { toast } from "@/hooks/use-toast"
import Link from "next/link"
import { useLanguage } from "@/src/contexts/LanguageContext"

export function SettingsAppearance() {
  const { theme, setTheme } = useTheme()
  const { t } = useLanguage();
  const [isLoading, setIsLoading] = useState(false)

  const handleSave = () => {
    setIsLoading(true)

    // Feature not available: No backend endpoint for admin to manage appearance settings.
    setTimeout(() => {
      setIsLoading(false)
      toast({
        title: t.settingsUpdatedTitle,
        description: t.appearanceSettingsUpdated,
      })
    }, 1000)
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>{t.appearanceSettingsTitle}</CardTitle>
        <CardDescription>{t.customizeLookAndFeel}</CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="space-y-4">
          <h3 className="text-lg font-medium">{t.theme}</h3>

          <RadioGroup defaultValue={theme || "light"} onValueChange={setTheme} className="grid grid-cols-3 gap-4">
            <div>
              <RadioGroupItem value="light" id="light" className="sr-only" />
              <Label
                htmlFor="light"
                className="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-popover p-4 hover:bg-accent hover:text-accent-foreground [&:has([data-state=checked])]:border-primary"
              >
                <div className="mb-2 h-24 w-full rounded-md bg-[#fff] shadow-sm"></div>
                <span className="text-center">{t.light}</span>
              </Label>
            </div>

            <div>
              <RadioGroupItem value="dark" id="dark" className="sr-only" />
              <Label
                htmlFor="dark"
                className="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-popover p-4 hover:bg-accent hover:text-accent-foreground [&:has([data-state=checked])]:border-primary"
              >
                <div className="mb-2 h-24 w-full rounded-md bg-[#1e1e1e] shadow-sm"></div>
                <span className="text-center">{t.dark}</span>
              </Label>
            </div>

            <div>
              <RadioGroupItem value="system" id="system" className="sr-only" />
              <Label
                htmlFor="system"
                className="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-popover p-4 hover:bg-accent hover:text-accent-foreground [&:has([data-state=checked])]:border-primary"
              >
                <div className="mb-2 h-24 w-full rounded-md bg-gradient-to-r from-[#fff] to-[#1e1e1e] shadow-sm"></div>
                <span className="text-center">{t.system}</span>
              </Label>
            </div>
          </RadioGroup>
        </div>

        <div className="space-y-2">
          <Label htmlFor="font-size">{t.fontSize}</Label>
          <Select defaultValue="medium">
            <SelectTrigger id="font-size">
              <SelectValue placeholder={t.selectFontSize} />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="small">{t.small}</SelectItem>
              <SelectItem value="medium">{t.medium}</SelectItem>
              <SelectItem value="large">{t.large}</SelectItem>
            </SelectContent>
          </Select>
          <p className="text-sm text-muted-foreground">{t.adjustFontSize}</p>
        </div>

        <div className="space-y-2">
          <Label htmlFor="density">{t.interfaceDensity}</Label>
          <Select defaultValue="comfortable">
            <SelectTrigger id="density">
              <SelectValue placeholder={t.selectInterfaceDensity} />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="compact">{t.compact}</SelectItem>
              <SelectItem value="comfortable">{t.comfortable}</SelectItem>
              <SelectItem value="spacious">{t.spacious}</SelectItem>
            </SelectContent>
          </Select>
          <p className="text-sm text-muted-foreground">{t.adjustSpacingDensity}</p>
        </div>

        <div className="space-y-2">
          <Label htmlFor="animations">{t.animations}</Label>
          <Select defaultValue="enabled">
            <SelectTrigger id="animations">
              <SelectValue placeholder={t.selectAnimationPreference} />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="enabled">{t.enabledAnimations}</SelectItem>
              <SelectItem value="reduced">{t.reduced}</SelectItem>
              <SelectItem value="disabled">{t.disabled}</SelectItem>
            </SelectContent>
          </Select>
          <p className="text-sm text-muted-foreground">{t.controlAnimations}</p>
        </div>
      </CardContent>
      <CardFooter className="flex justify-between">
        <Button variant="cancel">{t.resetToDefaults}</Button>
        <div className="space-x-2">
          <Button variant="info" asChild>
            <Link href="/dashboard/settings/appearance">{t.advancedThemeCustomization}</Link>
          </Button>
          <Button variant="save" onClick={handleSave} disabled={isLoading}>
            {isLoading ? t.saving : t.saveChanges}
          </Button>
        </div>
      </CardFooter>
    </Card>
  )
}
