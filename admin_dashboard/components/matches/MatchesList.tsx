"use client";

import { useState, useEffect } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Search,
  Filter,
  MoreHorizontal,
  Eye,
  Heart,
  Calendar,
  Clock,
} from "lucide-react";

interface Match {
  id: string;
  user1: {
    id: string;
    name: string;
    avatar: string;
    initials: string;
  };
  user2: {
    id: string;
    name: string;
    avatar: string;
    initials: string;
  };
  status: "active" | "inactive" | "blocked";
  matchDate: string;
  compatibility: number;
  lastInteraction: string;
  messageCount: number;
}

// ...removed all mock/sample data. Will fetch from backend below.

export function MatchesList() {
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [visibleMatches, setVisibleMatches] = useState<Match[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // No backend support for fetching matches as admin. Set proper error state.
    setLoading(false);
    setError("Match management feature is not available yet");
    setVisibleMatches([]);
  }, []);

  const filteredMatches = visibleMatches.filter((match) => {
    const matchesSearch =
      match.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
      match.user1.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      match.user2.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus =
      statusFilter === "all" || match.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  if (loading) {
    return (
      <div className="space-y-6">
        <Card>
          <CardContent className="h-80 flex items-center justify-center">
            <div className="text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mb-4 mx-auto"></div>
              <p>Loading matches...</p>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-6">
        <Card>
          <CardContent className="h-80 flex items-center justify-center">
            <div className="text-center">
              <div className="text-yellow-600 mb-4">
                <Heart className="h-12 w-12 mx-auto mb-2" />
              </div>
              <h3 className="text-lg font-semibold mb-2">Feature Coming Soon</h3>
              <p className="text-muted-foreground">{error}</p>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="flex items-center justify-center h-40 text-muted-foreground">
      <div className="text-center">
        <Heart className="h-12 w-12 mx-auto mb-2 text-gray-400" />
        <p>Feature not available: No backend support for admin to view matches.</p>
      </div>
    </div>
  );
}
