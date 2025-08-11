"use client";



import AddAccountForm from "@/components/admin/AddAccountForm";
import { Card, CardContent } from "@/components/ui/card";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { authService } from "@/src/services/auth.service";
import { useLanguage } from "@/src/contexts/LanguageContext";

export default function AddAccountPage() {
  const { t } = useLanguage();
  const [role, setRole] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    const user = authService.getCurrentUser();
    if (!user) {
      router.replace("/login");
      setLoading(true);
      return;
    }
    const roleName = user.roleName || null;
    setRole(roleName);
    if (roleName !== "ADMIN") {
      router.replace("/dashboard");
    }
    setLoading(false);
  }, [router]);

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh]">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mb-4"></div>
        <p className="text-muted-foreground">Loading...</p>
      </div>
    );
  }

  if (role !== "ADMIN") {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh]">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mb-4"></div>
        <p className="text-muted-foreground">Redirecting...</p>
      </div>
    );
  }

  // Giao diện gọn, chỉ 1 lớp nền trắng, giảm padding, không lồng Card
  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-pink-50 via-fuchsia-50 to-purple-50">
      <div className="w-full max-w-xl animate-fade-in bg-white rounded-2xl shadow-xl p-8 border">
        <h1 className="font-heading text-3xl font-extrabold tracking-tight mb-8 bg-gradient-to-r from-pink-500 via-fuchsia-500 to-purple-500 text-transparent bg-clip-text drop-shadow-lg animate-gradient-x text-center">
          {t.addAdminModeratorAccount}
        </h1>
        <AddAccountForm />
      </div>
    </div>
  );
}
