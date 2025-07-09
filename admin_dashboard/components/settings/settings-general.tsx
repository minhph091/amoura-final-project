"use client";

import { useState } from "react";
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

export function SettingsGeneral() {
  const [isLoading, setIsLoading] = useState(false);

  const handleSave = () => {
    setIsLoading(true);

    // Simulate API call
    setTimeout(() => {
      setIsLoading(false);
      toast({
        title: "Settings updated",
        description: "Your general settings have been updated successfully.",
      });
    }, 1000);
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>General Settings</CardTitle>
        <CardDescription>
          Manage your system-wide settings and preferences
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="space-y-2">
          <Label htmlFor="system-name">System Name</Label>
          <Input id="system-name" defaultValue="Amoura Admin Dashboard" />
          <p className="text-sm text-muted-foreground">
            This name will be displayed throughout the admin interface
          </p>
        </div>

        <div className="space-y-2">
          <Label htmlFor="contact-email">Support Email</Label>
          <Input
            id="contact-email"
            type="email"
            defaultValue="support@amoura.space"
          />
          <p className="text-sm text-muted-foreground">
            This email will be used for system notifications and user support
            requests
          </p>
        </div>

        <div className="space-y-2">
          <Label htmlFor="timezone">Default Timezone</Label>
          <Select defaultValue="utc">
            <SelectTrigger id="timezone">
              <SelectValue placeholder="Select timezone" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="utc">
                UTC (Coordinated Universal Time)
              </SelectItem>
              <SelectItem value="est">EST (Eastern Standard Time)</SelectItem>
              <SelectItem value="cst">CST (Central Standard Time)</SelectItem>
              <SelectItem value="mst">MST (Mountain Standard Time)</SelectItem>
              <SelectItem value="pst">PST (Pacific Standard Time)</SelectItem>
            </SelectContent>
          </Select>
          <p className="text-sm text-muted-foreground">
            System-wide default timezone for displaying dates and times
          </p>
        </div>

        <div className="space-y-2">
          <Label htmlFor="language">Default Language</Label>
          <Select defaultValue="en">
            <SelectTrigger id="language">
              <SelectValue placeholder="Select language" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="en">English</SelectItem>
              <SelectItem value="es">Spanish</SelectItem>
              <SelectItem value="fr">French</SelectItem>
              <SelectItem value="de">German</SelectItem>
              <SelectItem value="zh">Chinese</SelectItem>
            </SelectContent>
          </Select>
          <p className="text-sm text-muted-foreground">
            System-wide default language
          </p>
        </div>

        <div className="space-y-2">
          <Label htmlFor="maintenance-message">Maintenance Message</Label>
          <Textarea
            id="maintenance-message"
            placeholder="Enter a message to display during maintenance mode"
            defaultValue="We're currently performing scheduled maintenance. Please check back soon."
          />
          <p className="text-sm text-muted-foreground">
            This message will be displayed to users when maintenance mode is
            enabled
          </p>
        </div>
      </CardContent>
      <CardFooter className="flex justify-between">
        <Button variant="outline">Reset</Button>
        <Button onClick={handleSave} disabled={isLoading}>
          {isLoading ? "Saving..." : "Save Changes"}
        </Button>
      </CardFooter>
    </Card>
  );
}
