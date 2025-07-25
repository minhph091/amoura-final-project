"use client";

import type React from "react";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Lock, User, Eye, EyeOff } from "lucide-react";
import { AmouraLogo } from "@/components/ui/AmouraLogo";
import { authService } from "@/src/services/auth.service";
import type { LoginRequest } from "@/src/types/auth.types";
import { useLanguage } from "@/src/contexts/LanguageContext";
import { LanguageSwitcher } from "@/components/LanguageSwitcher";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();
  const { t } = useLanguage();

  // Check if already logged in
  useEffect(() => {
    if (authService.isAuthenticated() && authService.isAdminOrModerator()) {
      router.push("/dashboard");
    }
  }, [router]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setIsLoading(true);

    if (!email || !password) {
      setError(t.login.invalidCredentials);
      setIsLoading(false);
      return;
    }

    try {
      const res = await fetch("/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email,
          password,
          loginType: "EMAIL_PASSWORD", // Chuẩn backend
        }),
      });
      if (res.ok) {
        const data = await res.json();
        // Kiểm tra roleName chuẩn backend
        if (data.user?.roleName === "ADMIN" || data.user?.roleName === "MODERATOR") {
          localStorage.setItem("auth_token", data.accessToken);
          localStorage.setItem("refresh_token", data.refreshToken);
          localStorage.setItem("user_data", JSON.stringify(data.user));
          router.push("/dashboard");
        } else {
          setError(
            "Bạn không có quyền truy cập trang quản trị. Chỉ ADMIN hoặc MODERATOR mới được phép đăng nhập."
          );
        }
      } else {
        let errorMsg = "Login failed";
        try {
          const errorData = await res.json();
          errorMsg = errorData.message || errorMsg;
        } catch {}
        setError(errorMsg);
      }
    } catch (error) {
      setError("An unexpected error occurred");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex bg-purple-600 relative overflow-hidden">
      {/* Left Side - Welcome Section with Fluid Background */}
      <div className="hidden lg:flex lg:w-1/2 bg-fluid-gradient relative">
        {/* Animated floating shapes */}
        <div className="floating-shape pulse-shape"></div>
        <div className="floating-shape"></div>
        <div className="floating-shape pulse-shape"></div>
        <div className="floating-shape"></div>
        <div className="floating-shape pulse-shape"></div>
        {/* Wave decoration */}
        <div className="wave-shape"></div>
        <div className="flex flex-col justify-center items-center px-12 text-white relative z-10 w-full h-full">
          <div className="text-center space-y-8 flex flex-col items-center justify-center">
            <div className="flex justify-center mb-8">
              <div className="bg-white/20 backdrop-blur-sm rounded-2xl p-8 shadow-2xl">
                <AmouraLogo size="large" />
              </div>
            </div>
            <h1 className="font-heading text-5xl lg:text-6xl font-bold mb-6 leading-tight">
              Amoura
            </h1>
            <p className="font-primary text-white/90 text-xl leading-relaxed max-w-md text-center">
              Where stars align for love to begin.
            </p>
            <div className="flex items-center justify-center space-x-2 text-sm text-white/70 mt-12">
              <span className="font-medium">WWW.AMOURA.SPACE</span>
            </div>
          </div>
        </div>
      </div>
      {/* Right Side - Login Form */}
      <div className="w-full lg:w-1/2 flex items-center justify-center bg-white p-8 relative">
        {/* Language Switcher */}
        <div className="absolute top-4 right-4">
          <LanguageSwitcher />
        </div>
        <div className="w-full max-w-md">
          {/* Mobile logo */}
          <div className="lg:hidden text-center mb-8">
            <AmouraLogo size="large" />
          </div>
          <div className="space-y-8">
            <div className="text-left">
              <h1 className="font-heading text-4xl font-bold bg-gradient-to-r from-pink-500 via-purple-500 to-pink-600 bg-clip-text text-transparent mb-4">
                {t.login.welcomeBack}
              </h1>
              <p className="font-primary text-gray-600 text-lg">
                {t.login.subtitle}
              </p>
            </div>
            <form onSubmit={handleLogin} className="space-y-6">
              {error && (
                <div className="bg-red-50 border border-red-200 text-red-700 text-sm p-3 rounded-lg">
                  {error}
                </div>
              )}
              <div className="space-y-2">
                <Label
                  htmlFor="email"
                  className="text-gray-600 font-medium font-primary text-sm sr-only"
                >
                  {t.login.email}
                </Label>
                <div className="relative">
                  <User className="absolute left-3 top-3 h-5 w-5 text-gray-500" />
                  <Input
                    id="email"
                    type="email"
                    placeholder={t.login.emailPlaceholder}
                    className="pl-10 bg-transparent border-0 border-b-2 border-gray-300 focus:border-pink-500 text-gray-900 placeholder-gray-500 rounded-none py-3 focus:ring-0"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                  />
                </div>
              </div>
              <div className="space-y-2">
                <Label
                  htmlFor="password"
                  className="text-gray-600 font-medium font-primary text-sm sr-only"
                >
                  {t.login.password}
                </Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-3 h-5 w-5 text-gray-500" />
                  <Input
                    id="password"
                    type={showPassword ? "text" : "password"}
                    placeholder={t.login.passwordPlaceholder}
                    className="pl-10 pr-10 bg-transparent border-0 border-b-2 border-gray-300 focus:border-pink-500 text-gray-900 placeholder-gray-500 rounded-none py-3 focus:ring-0"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                  />
                  <button
                    type="button"
                    className="absolute right-3 top-3 h-5 w-5 text-gray-500 hover:text-gray-700"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? (
                      <EyeOff className="h-5 w-5" />
                    ) : (
                      <Eye className="h-5 w-5" />
                    )}
                  </button>
                </div>
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  <input
                    type="checkbox"
                    id="remember"
                    className="w-4 h-4 text-pink-500 bg-transparent border-gray-400 rounded focus:ring-pink-500"
                    title={t.login.rememberMe}
                  />
                  <Label htmlFor="remember" className="text-sm text-gray-600">
                    {t.login.rememberMe}
                  </Label>
                </div>
                <button
                  type="button"
                  className="text-sm text-gray-600 hover:text-gray-800 transition-colors"
                >
                  Forgot password?
                </button>
              </div>
              <Button
                className="w-full bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 text-white shadow-lg font-medium py-4 rounded-full transition-all duration-300 text-lg"
                type="submit"
                disabled={isLoading}
              >
                {isLoading ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Logging in...
                  </>
                ) : (
                  t.login.loginButton
                )}
              </Button>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
}
