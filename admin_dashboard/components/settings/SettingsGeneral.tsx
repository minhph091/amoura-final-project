"use client";

import { useState, useEffect } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { toast } from "@/hooks/use-toast";
import { useLanguage } from "@/src/contexts/LanguageContext";

export function SettingsGeneral() {
  const { t, language, setLanguage } = useLanguage();
  const [isLoading, setIsLoading] = useState(false);
  const [selectedLanguage, setSelectedLanguage] = useState<string>(language);

  // Sync with current language from context
  useEffect(() => {
    setSelectedLanguage(language);
  }, [language]);

  const handleSave = () => {
    setIsLoading(true);

    // Apply language change if different from current
    if (selectedLanguage !== language) {
      setLanguage(selectedLanguage as "en" | "vi");
      toast({
        title: t.settingsUpdatedTitle,
        description: `Language changed to ${selectedLanguage === "en" ? "English" : "Tiếng Việt"}`,
      });
    } else {
      toast({
        title: t.settingsUpdatedTitle,
        description: t.settingsUpdatedDescription,
      });
    }

    setTimeout(() => {
      setIsLoading(false);
    }, 1000);
  };

  const handleLanguageChange = (value: string) => {
    setSelectedLanguage(value);
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>{t.generalSettingsTab}</CardTitle>
        <CardDescription>
          {t.manageSystemSettings}
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="space-y-2">
          <Label htmlFor="system-name">{t.systemNameField}</Label>
          <Input id="system-name" defaultValue={t.amouraAdminDashboardTitle} />
          <p className="text-sm text-muted-foreground">
            {t.thisNameDisplayed}
          </p>
        </div>

        <div className="space-y-2">
          <Label htmlFor="contact-email">{t.supportEmailField}</Label>
          <Input
            id="contact-email"
            type="email"
            defaultValue={t.supportEmailDefault}
          />
          <p className="text-sm text-muted-foreground">
            {t.emailUsedForSystemNotifications}
          </p>
        </div>

        <div className="space-y-2">
          <Label htmlFor="timezone">{t.defaultTimezoneField}</Label>
          <Select defaultValue="utc">
            <SelectTrigger id="timezone">
              <SelectValue placeholder={t.selectTimezone} />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="utc">
                {t.utcCoordinatedUniversalTime}
              </SelectItem>
              <SelectItem value="est">{t.estTime}</SelectItem>
              <SelectItem value="cst">{t.cstTime}</SelectItem>
              <SelectItem value="mst">{t.mstTime}</SelectItem>
              <SelectItem value="pst">{t.pstTime}</SelectItem>
            </SelectContent>
          </Select>
          <p className="text-sm text-muted-foreground">
            {t.systemWideDefaultTimezone}
          </p>
        </div>

        <div className="space-y-2">
          <Label htmlFor="language">{t.defaultLanguageField}</Label>
          <Select value={selectedLanguage} onValueChange={handleLanguageChange}>
            <SelectTrigger id="language">
              <SelectValue placeholder={t.selectLanguage} />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="en">{t.englishLanguage}</SelectItem>
              <SelectItem value="vi">Tiếng Việt</SelectItem>
            </SelectContent>
          </Select>
          <p className="text-sm text-muted-foreground">
            {t.systemWideDefaultLanguage}
          </p>
        </div>

        <div className="space-y-2">
          <Label htmlFor="maintenance-message">{t.maintenanceMessageField}</Label>
          <Textarea
            id="maintenance-message"
            placeholder={t.maintenanceMessagePlaceholder}
            defaultValue={t.currentlyPerformingMaintenance}
          />
          <p className="text-sm text-muted-foreground">
            {t.messageDisplayedMaintenanceMode}
          </p>
        </div>
      </CardContent>
      <CardFooter className="flex justify-between">
        <Button variant="cancel">{t.reset}</Button>
        <Button variant="save" onClick={handleSave} disabled={isLoading}>
          {isLoading ? t.savingText : t.saveChangesButton}
        </Button>
      </CardFooter>
    </Card>
  );
}
