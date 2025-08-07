"use client";

import { Textarea } from "@/components/ui/textarea";
import { useState } from "react";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { toast } from "@/hooks/use-toast";
import { ChangePasswordForm } from "./ChangePasswordForm";
import { useLanguage } from "@/src/contexts/LanguageContext";

export function SettingsSecurity() {
  const { t } = useLanguage();
  const [isLoading, setIsLoading] = useState(false);

  const handleSave = () => {
    setIsLoading(true);

    // Feature not available: No backend endpoint for admin to manage security settings.
    setTimeout(() => {
      setIsLoading(false);
      toast({
        title: t.settingsUpdatedTitle,
        description: t.securitySettingsUpdated,
      });
    }, 1000);
  };

  return (
    <div className="space-y-6">
      {/* Change Password Form */}
      <ChangePasswordForm />

      {/* Other Security Settings */}
      <Card>
        <CardHeader>
          <CardTitle>{t.securitySettings}</CardTitle>
          <CardDescription>{t.manageSecuritySettings}</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <Label htmlFor="2fa">{t.twoFactorAuthentication}</Label>
              <Switch id="2fa" defaultChecked />
            </div>
            <p className="text-sm text-muted-foreground">
              {t.twoFactorAuthDescription}
            </p>
          </div>

          <div className="space-y-2">
            <Label htmlFor="session-timeout">{t.sessionTimeout}</Label>
            <Select defaultValue="60">
              <SelectTrigger id="session-timeout">
                <SelectValue placeholder={t.selectTimeoutPeriod} />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="15">{t.fifteenMinutes}</SelectItem>
                <SelectItem value="30">{t.thirtyMinutes}</SelectItem>
                <SelectItem value="60">{t.oneHour}</SelectItem>
                <SelectItem value="120">{t.twoHours}</SelectItem>
                <SelectItem value="240">{t.fourHours}</SelectItem>
              </SelectContent>
            </Select>
            <p className="text-sm text-muted-foreground">
              {t.sessionTimeoutDescription}
            </p>
          </div>

          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <Label htmlFor="ip-restriction">{t.ipAddressRestriction}</Label>
              <Switch id="ip-restriction" />
            </div>
            <p className="text-sm text-muted-foreground">{t.ipRestrictionDescription}</p>
          </div>

          <div className="space-y-2">
            <Label htmlFor="allowed-ips">{t.allowedIpAddresses}</Label>
            <Textarea id="allowed-ips" placeholder={t.enterIpAddresses} className="h-20" />
            <p className="text-sm text-muted-foreground">
              {t.ipAddressesDescription}
            </p>
          </div>

          <div className="space-y-2">
            <Label htmlFor="password-policy">{t.passwordPolicy}</Label>
            <Select defaultValue="strong">
              <SelectTrigger id="password-policy">
                <SelectValue placeholder={t.selectPasswordPolicy} />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="basic">{t.basicPolicy}</SelectItem>
                <SelectItem value="medium">{t.mediumPolicy}</SelectItem>
                <SelectItem value="strong">{t.strongPolicy}</SelectItem>
                <SelectItem value="custom">{t.customPolicy}</SelectItem>
              </SelectContent>
            </Select>
            <p className="text-sm text-muted-foreground">{t.passwordPolicyDescription}</p>
          </div>

          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <Label htmlFor="audit-logging">{t.auditLogging}</Label>
              <Switch id="audit-logging" defaultChecked />
            </div>
            <p className="text-sm text-muted-foreground">{t.auditLoggingDescription}</p>
          </div>
        </CardContent>
        <CardFooter className="flex justify-between">
          <Button variant="cancel">{t.reset}</Button>
          <Button variant="save" onClick={handleSave} disabled={isLoading}>
            {isLoading ? t.saving : t.saveChanges}
          </Button>
        </CardFooter>
      </Card>
    </div>
  );
}
