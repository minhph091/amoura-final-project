"use client";

import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Search,
  Filter,
  Crown,
  Calendar,
  CreditCard,
  MoreHorizontal,
} from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useLanguage } from "@/src/contexts/LanguageContext";

import { useEffect } from "react";
// Feature not available: No backend endpoint for admin to fetch subscriptions.

interface Subscription {
  id: string;
  user: {
    name: string;
    email: string;
    avatar: string;
    initials: string;
  };
  plan: "free" | "premium";
  status: "active" | "expired" | "canceled";
  startDate: string;
  endDate: string;
  billingCycle: "monthly" | "yearly";
  amount: string;
  paymentMethod: string;
  autoRenew: boolean;
}

// ...removed all mock/sample data. Will fetch from backend below.

export function SubscriptionsList() {
  const { t } = useLanguage();
  const [searchTerm, setSearchTerm] = useState("");
  const [planFilter, setPlanFilter] = useState("all");
  const [statusFilter, setStatusFilter] = useState("all");
  const [subscriptions, setSubscriptions] = useState<Subscription[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // No backend support for fetching subscriptions as admin. Show not available.
    setLoading(false);
  }, []);

  const filteredSubscriptions = subscriptions.filter(
    (subscription: Subscription) => {
      const matchesSearch =
        subscription.user.name
          .toLowerCase()
          .includes(searchTerm.toLowerCase()) ||
        subscription.user.email
          .toLowerCase()
          .includes(searchTerm.toLowerCase()) ||
        subscription.id.toLowerCase().includes(searchTerm.toLowerCase());
      const matchesPlan =
        planFilter === "all" || subscription.plan === planFilter;
      const matchesStatus =
        statusFilter === "all" || subscription.status === statusFilter;
      return matchesSearch && matchesPlan && matchesStatus;
    }
  );

  return (
    <div className="flex items-center justify-center h-40 text-muted-foreground">
      {t.featureComingSoon}
    </div>
  );
}
