"use client"

import { useState, useEffect } from "react"
import { Card, CardContent } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Search, Filter, MoreHorizontal, Eye, AlertTriangle, CheckCircle, Clock } from "lucide-react"

interface Message {
  id: string
  sender: {
    id: string
    name: string
    avatar: string
    initials: string
  }
  recipient: {
    id: string
    name: string
    avatar: string
    initials: string
  }
  content: string
  timestamp: string
  status: "sent" | "delivered" | "read" | "flagged"
  flagReason?: string
}


export function MessagesList() {
  return (
    <div className="flex items-center justify-center h-40 text-muted-foreground">
      Feature not available: No backend support for admin to view messages.
    </div>
  );
}