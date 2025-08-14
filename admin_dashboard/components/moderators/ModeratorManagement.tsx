
"use client";

import { useState, useEffect } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { DropdownMenu, DropdownMenuTrigger, DropdownMenuContent, DropdownMenuItem } from "@/components/ui/dropdown-menu";
import { UserX, UserCheck, MoreHorizontal } from "lucide-react";
import { useLanguage } from "@/src/contexts/LanguageContext";

interface Moderator {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  initials: string;
  role: string;
  status: string;
  joinDate: string;
  reportsHandled: number;
}


import { moderatorService } from "@/src/services/moderator.service";
import ModeratorPasswordDialog from "./ModeratorPasswordDialog";


export default function ModeratorManagement() {
  const { t } = useLanguage();
  const [moderators, setModerators] = useState<Moderator[]>([]);
  const [filteredModerators, setFilteredModerators] = useState<Moderator[]>([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [pwDialogOpen, setPwDialogOpen] = useState(false);
  const [selectedEmail, setSelectedEmail] = useState<string>("");

  useEffect(() => {
    let mounted = true;
    setLoading(true);
    moderatorService.getModerators()
      .then((res) => {
        if (mounted) {
          if (res.success && res.data) {
            // Map backend fields to UI fields if needed
            const mods = res.data.map((m: any) => ({
              id: m.id?.toString() || "",
              name: m.name || m.username || "Unknown",
              email: m.email || "",
              avatar: m.avatar || "",
              initials: m.name ? m.name.split(" ").map((n: string) => n[0]).join("") : "?",
              role: m.role || "MODERATOR",
              status: m.status || "active",
              joinDate: m.createdAt || "",
              reportsHandled: m.reportsHandled || 0,
            }));
            setModerators(mods);
            setFilteredModerators(mods);
          } else {
            setModerators([]);
            setFilteredModerators([]);
          }
          setLoading(false);
        }
      })
      .catch(() => {
        if (mounted) {
          setModerators([]);
          setFilteredModerators([]);
          setLoading(false);
        }
      });
    return () => {
      mounted = false;
    };
  }, []);

  useEffect(() => {
    if (!search) {
      setFilteredModerators(moderators);
    } else {
      setFilteredModerators(
        moderators.filter((m) =>
          m.name.toLowerCase().includes(search.toLowerCase()) ||
          m.email.toLowerCase().includes(search.toLowerCase())
        )
      );
    }
  }, [search, moderators]);

  const handleDisableModerator = (moderator: Moderator) => {
    // TODO: Implement disable logic
  };
  const handleEnableModerator = (moderator: Moderator) => {
    // TODO: Implement enable logic
  };

  return (
    <div className="p-4">
      <ModeratorPasswordDialog open={pwDialogOpen} onOpenChange={setPwDialogOpen} moderatorEmail={selectedEmail} />
      
      {/* Alert about moderator feature status */}
      <Card className="mb-4 border-orange-200 bg-orange-50">
        <CardContent>
          <div className="flex items-center gap-3 p-4">
            <div className="w-3 h-3 bg-orange-500 rounded-full"></div>
            <div>
              <h4 className="font-medium text-orange-800">{t.moderatorManagement}</h4>
              <p className="text-sm text-orange-700">
                {t.featureComingSoon}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent>
          <div className="flex items-center justify-between mb-4 mt-4">
            <Input
              placeholder={t.searchModerators}
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="max-w-xs"
            />
          </div>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b bg-muted/40">
                  <th className="text-left py-4 px-4 font-bold text-base">Moderator</th>
                  <th className="text-left py-4 px-4 font-bold text-base">{t.role}</th>
                  <th className="text-left py-4 px-4 font-bold text-base">{t.status}</th>
                  <th className="text-left py-4 px-4 font-bold text-base hidden md:table-cell">Join Date</th>
                  <th className="text-left py-4 px-4 font-bold text-base hidden lg:table-cell">{t.reportsHandled}</th>
                  <th className="text-right py-4 px-4 font-bold text-base">{t.actions}</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={6} className="py-10 text-center text-muted-foreground">
                      {t.loadingText}
                    </td>
                  </tr>
                ) : filteredModerators.length > 0 ? (
                  filteredModerators.map((moderator) => (
                    <tr key={moderator.id} className="border-b animate-fade-in">
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-3">
                          <Avatar>
                            <AvatarImage src={moderator.avatar || "/placeholder.svg"} alt={moderator.name} />
                            <AvatarFallback>{moderator.initials}</AvatarFallback>
                          </Avatar>
                          <div>
                            <div className="font-medium">{moderator.name}</div>
                            <div className="text-sm text-muted-foreground">{moderator.email}</div>
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <Badge variant="outline" className="capitalize">{moderator.role}</Badge>
                      </td>
                      <td className="py-3 px-4">
                        <Badge
                          variant={moderator.status === "active" ? "default" : "secondary"}
                          className={moderator.status === "active" ? "bg-green-500" : ""}
                        >
                          {moderator.status.charAt(0).toUpperCase() + moderator.status.slice(1)}
                        </Badge>
                      </td>
                      <td className="py-3 px-4 hidden md:table-cell">{moderator.joinDate}</td>
                      <td className="py-3 px-4 hidden lg:table-cell">{moderator.reportsHandled}</td>
                      <td className="py-3 px-4 text-right">
                        <div className="flex justify-end gap-2">
                          {moderator.status === "active" ? (
                            <Button variant="ghost" size="icon" className="text-destructive" onClick={() => handleDisableModerator(moderator)}>
                              <UserX className="h-4 w-4" />
                            </Button>
                          ) : (
                            <Button variant="ghost" size="icon" className="text-green-500" onClick={() => handleEnableModerator(moderator)}>
                              <UserCheck className="h-4 w-4" />
                            </Button>
                          )}
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon">
                                <MoreHorizontal className="h-4 w-4" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              <DropdownMenuItem>{t.details}</DropdownMenuItem>
                              <DropdownMenuItem>Edit Permissions</DropdownMenuItem>
                              <DropdownMenuItem onClick={() => { setSelectedEmail(moderator.email); setPwDialogOpen(true); }}>Reset Password</DropdownMenuItem>
                              {moderator.status === "active" ? (
                                <DropdownMenuItem className="text-destructive" onClick={() => handleDisableModerator(moderator)}>
                                  Disable Account
                                </DropdownMenuItem>
                              ) : (
                                <DropdownMenuItem className="text-green-500" onClick={() => handleEnableModerator(moderator)}>
                                  Enable Account
                                </DropdownMenuItem>
                              )}
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </div>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={6} className="py-10 text-center text-muted-foreground">
                      {t.noModeratorsFound}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
