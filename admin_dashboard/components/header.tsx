"use client";


import { useState, useEffect, useContext, createContext } from "react";
// Context to share header search term with sidebar
export const HeaderSearchContext = createContext({ search: "", setSearch: (_: string) => {} });
import { useRouter } from "next/navigation";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { LogOut, Moon, Settings, Sun, User, Search } from "lucide-react";
import { useThemeSafe } from "@/hooks/use-theme-safe";
import { Input } from "@/components/ui/input";
import { AmouraLogo } from "@/components/ui/AmouraLogo";
import { LanguageSwitcher } from "@/components/LanguageSwitcher";
import { useLanguage } from "@/src/contexts/LanguageContext";
import { profileService } from "@/src/services/profile.service";
import { authService } from "@/src/services/auth.service";


export function Header() {
  const { theme, setTheme, mounted } = useThemeSafe();
  const { t } = useLanguage();
  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const router = useRouter();

  useEffect(() => {
    async function fetchUser() {
      setLoading(true);
      try {
        const res = await profileService.getMyProfile();
        if (res.success && res.data) {
          setUser(res.data);
        } else {
          setUser(null);
        }
      } catch {
        setUser(null);
      } finally {
        setLoading(false);
      }
    }
    fetchUser();
  }, []);

  const handleLogout = async () => {
    await authService.logout();
    router.push("/login");
  };

  if (loading) return null;
  if (!user) return null;

  return (
    <HeaderSearchContext.Provider value={{ search, setSearch }}>
      <header className="fixed top-0 right-0 z-30 border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 transition-all duration-300 ease-in-out w-full lg:w-auto lg:left-64">
        <div className="flex h-16 items-center px-6 justify-between">
          {/* Left Side - Logo for mobile */}
          <div className="flex items-center space-x-4 md:hidden">
            <AmouraLogo size="small" />
          </div>

          {/* Center - Search Bar */}
          <div className="flex-1 max-w-lg mx-4 hidden md:block">
            <div className="relative">
              <Search className="absolute left-3 top-2.5 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder={t.header.searchPlaceholder}
                className="pl-10 bg-muted/50 border-0 focus:bg-background"
                value={search}
                onChange={e => setSearch(e.target.value)}
              />
            </div>
          </div>

          {/* Right Side - Actions */}
          <div className="flex items-center space-x-4">
            {/* Search for mobile */}
            <Button variant="ghost" size="icon" className="md:hidden">
              <Search className="h-5 w-5" />
            </Button>

            {/* Language Switcher */}
            <LanguageSwitcher />

            {/* Theme Switcher */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" size="icon">
                  {!mounted ? (
                    <div className="h-5 w-5" />
                  ) : theme === "dark" ? (
                    <Moon className="h-5 w-5" />
                  ) : theme === "light" ? (
                    <Sun className="h-5 w-5" />
                  ) : (
                    <div className="h-5 w-5 rounded-full bg-gradient-to-r from-black to-white" />
                  )}
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuItem onClick={() => setTheme("light")}> 
                  <Sun className="mr-2 h-4 w-4" />
                  <span>{t.header.light}</span>
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => setTheme("dark")}> 
                  <Moon className="mr-2 h-4 w-4" />
                  <span>{t.header.dark}</span>
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => setTheme("system")}> 
                  <div className="mr-2 h-4 w-4 rounded-full bg-gradient-to-r from-black to-white" />
                  <span>{t.header.system}</span>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>

            {/* User Menu */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button
                  variant="ghost"
                  className="relative h-10 w-10 rounded-full"
                >
                  <Avatar className="h-10 w-10">
                    <AvatarImage
                      src={user?.photos?.find((p:any)=>p.type==="AVATAR")?.url || "/placeholder-user.jpg"}
                      alt={user?.firstName || "User"}
                    />
                    <AvatarFallback>{user?.firstName?.[0] || "U"}</AvatarFallback>
                  </Avatar>
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56">
                <div className="flex items-center justify-start gap-2 p-2">
                  <div className="flex flex-col space-y-1 leading-none">
                    <p className="font-heading font-semibold">
                      {user?.displayName || `${user?.firstName || ""} ${user?.lastName || ""}`}
                    </p>
                    <p className="text-sm text-muted-foreground font-primary">
                      {user?.email}
                    </p>
                  </div>
                </div>
                <DropdownMenuSeparator />
                <DropdownMenuItem
                  onClick={() => router.push("/dashboard/profile")}
                >
                  <User className="mr-2 h-4 w-4" />
                  <span>{t.header.profile}</span>
                </DropdownMenuItem>
                <DropdownMenuItem
                  onClick={() => router.push("/dashboard/settings")}
                >
                  <Settings className="mr-2 h-4 w-4" />
                  <span>{t.header.settings}</span>
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={handleLogout} className="text-red-600">
                  <LogOut className="mr-2 h-4 w-4" />
                  <span>{t.header.logout}</span>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </header>
    </HeaderSearchContext.Provider>
  );
}
