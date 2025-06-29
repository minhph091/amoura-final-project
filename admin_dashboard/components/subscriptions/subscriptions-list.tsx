"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Search, Filter, Crown, Calendar, CreditCard, MoreHorizontal } from "lucide-react"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"

interface Subscription {
  id: string
  user: {
    name: string
    email: string
    avatar: string
    initials: string
  }
  plan: "free" | "premium"
  status: "active" | "expired" | "canceled"
  startDate: string
  endDate: string
  billingCycle: "monthly" | "yearly"
  amount: string
  paymentMethod: string
  autoRenew: boolean
}

const subscriptions: Subscription[] = [
  {
    id: "SUB-1001",
    user: {
      name: "Sarah Johnson",
      email: "sarah.j@example.com",
      avatar: "https://randomuser.me/api/portraits/women/12.jpg",
      initials: "SJ",
    },
    plan: "premium",
    status: "active",
    startDate: "May 1, 2023",
    endDate: "May 1, 2024",
    billingCycle: "yearly",
    amount: "$99.99",
    paymentMethod: "Visa •••• 4242",
    autoRenew: true,
  },
  {
    id: "SUB-1002",
    user: {
      name: "Alex Wong",
      email: "alex.w@example.com",
      avatar: "https://randomuser.me/api/portraits/men/22.jpg",
      initials: "AW",
    },
    plan: "premium",
    status: "active",
    startDate: "Apr 15, 2023",
    endDate: "May 15, 2023",
    billingCycle: "monthly",
    amount: "$9.99",
    paymentMethod: "Mastercard •••• 5555",
    autoRenew: true,
  },
  {
    id: "SUB-1003",
    user: {
      name: "Maria Garcia",
      email: "maria.g@example.com",
      avatar: "https://randomuser.me/api/portraits/women/28.jpg",
      initials: "MG",
    },
    plan: "free",
    status: "active",
    startDate: "Mar 10, 2023",
    endDate: "N/A",
    billingCycle: "monthly",
    amount: "$0.00",
    paymentMethod: "N/A",
    autoRenew: false,
  },
  {
    id: "SUB-1004",
    user: {
      name: "James Smith",
      email: "james.s@example.com",
      avatar: "https://randomuser.me/api/portraits/men/32.jpg",
      initials: "JS",
    },
    plan: "premium",
    status: "canceled",
    startDate: "Feb 5, 2023",
    endDate: "Mar 5, 2023",
    billingCycle: "monthly",
    amount: "$9.99",
    paymentMethod: "PayPal",
    autoRenew: false,
  },
  {
    id: "SUB-1005",
    user: {
      name: "Aisha Patel",
      email: "aisha.p@example.com",
      avatar: "https://randomuser.me/api/portraits/women/44.jpg",
      initials: "AP",
    },
    plan: "premium",
    status: "active",
    startDate: "Jan 20, 2023",
    endDate: "Jan 20, 2024",
    billingCycle: "yearly",
    amount: "$99.99",
    paymentMethod: "Visa •••• 1234",
    autoRenew: true,
  },
  {
    id: "SUB-1006",
    user: {
      name: "David Kim",
      email: "david.k@example.com",
      avatar: "https://randomuser.me/api/portraits/men/45.jpg",
      initials: "DK",
    },
    plan: "free",
    status: "active",
    startDate: "Jan 15, 2023",
    endDate: "N/A",
    billingCycle: "monthly",
    amount: "$0.00",
    paymentMethod: "N/A",
    autoRenew: false,
  },
  {
    id: "SUB-1007",
    user: {
      name: "Emma Wilson",
      email: "emma.w@example.com",
      avatar: "https://randomuser.me/api/portraits/women/17.jpg",
      initials: "EW",
    },
    plan: "premium",
    status: "expired",
    startDate: "Dec 10, 2022",
    endDate: "Jan 10, 2023",
    billingCycle: "monthly",
    amount: "$9.99",
    paymentMethod: "Mastercard •••• 8888",
    autoRenew: false,
  },
]

export function SubscriptionsList() {
  const [searchTerm, setSearchTerm] = useState("")
  const [planFilter, setPlanFilter] = useState("all")
  const [statusFilter, setStatusFilter] = useState("all")

  const filteredSubscriptions = subscriptions.filter((subscription) => {
    const matchesSearch =
      subscription.user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      subscription.user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      subscription.id.toLowerCase().includes(searchTerm.toLowerCase())

    const matchesPlan = planFilter === "all" || subscription.plan === planFilter
    const matchesStatus = statusFilter === "all" || subscription.status === statusFilter

    return matchesSearch && matchesPlan && matchesStatus
  })

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>Subscription Management</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex flex-col md:flex-row gap-4 mb-6">
            <div className="relative flex-1">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
              <Input
                type="search"
                placeholder="Search by name, email, or ID..."
                className="pl-8"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
            <div className="flex gap-2">
              <Select value={planFilter} onValueChange={setPlanFilter}>
                <SelectTrigger className="w-[150px]">
                  <div className="flex items-center gap-2">
                    <Crown className="h-4 w-4" />
                    <SelectValue placeholder="Filter by plan" />
                  </div>
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Plans</SelectItem>
                  <SelectItem value="free">Free</SelectItem>
                  <SelectItem value="premium">Premium</SelectItem>
                </SelectContent>
              </Select>
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-[150px]">
                  <div className="flex items-center gap-2">
                    <Filter className="h-4 w-4" />
                    <SelectValue placeholder="Filter by status" />
                  </div>
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Statuses</SelectItem>
                  <SelectItem value="active">Active</SelectItem>
                  <SelectItem value="expired">Expired</SelectItem>
                  <SelectItem value="canceled">Canceled</SelectItem>
                </SelectContent>
              </Select>
              <Button>Export</Button>
            </div>
          </div>

          <Tabs defaultValue="all">
            <TabsList className="mb-4">
              <TabsTrigger value="all">All Subscriptions</TabsTrigger>
              <TabsTrigger value="active">Active</TabsTrigger>
              <TabsTrigger value="expired">Expired</TabsTrigger>
              <TabsTrigger value="canceled">Canceled</TabsTrigger>
            </TabsList>

            <TabsContent value="all" className="m-0">
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="border-b bg-muted/40">
                      <th className="text-left py-4 px-4 font-bold text-base">User</th>
                      <th className="text-left py-4 px-4 font-bold text-base">Plan</th>
                      <th className="text-left py-4 px-4 font-bold text-base">Status</th>
                      <th className="text-left py-4 px-4 font-bold text-base hidden md:table-cell">Start Date</th>
                      <th className="text-left py-4 px-4 font-bold text-base hidden lg:table-cell">End Date</th>
                      <th className="text-left py-4 px-4 font-bold text-base hidden lg:table-cell">Amount</th>
                      <th className="text-right py-4 px-4 font-bold text-base">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredSubscriptions.map((subscription) => (
                      <tr key={subscription.id} className="border-b animate-fade-in">
                        <td className="py-3 px-4">
                          <div className="flex items-center gap-3">
                            <Avatar>
                              <AvatarImage
                                src={subscription.user.avatar || "/placeholder.svg"}
                                alt={subscription.user.name}
                              />
                              <AvatarFallback>{subscription.user.initials}</AvatarFallback>
                            </Avatar>
                            <div>
                              <div className="font-medium">{subscription.user.name}</div>
                              <div className="text-sm text-muted-foreground">{subscription.user.email}</div>
                            </div>
                          </div>
                        </td>
                        <td className="py-3 px-4">
                          <Badge
                            variant={subscription.plan === "premium" ? "default" : "outline"}
                            className={subscription.plan === "premium" ? "bg-primary" : ""}
                          >
                            {subscription.plan === "premium" ? (
                              <span className="flex items-center">
                                <Crown className="h-3 w-3 mr-1" />
                                Premium
                              </span>
                            ) : (
                              "Free"
                            )}
                          </Badge>
                        </td>
                        <td className="py-3 px-4">
                          <Badge
                            variant={
                              subscription.status === "active"
                                ? "default"
                                : subscription.status === "expired"
                                  ? "outline"
                                  : "destructive"
                            }
                            className={
                              subscription.status === "active"
                                ? "bg-green-500"
                                : subscription.status === "expired"
                                  ? "border-yellow-500 text-yellow-500"
                                  : ""
                            }
                          >
                            {subscription.status.charAt(0).toUpperCase() + subscription.status.slice(1)}
                          </Badge>
                        </td>
                        <td className="py-3 px-4 hidden md:table-cell">
                          <div className="flex items-center">
                            <Calendar className="h-3.5 w-3.5 mr-1.5 text-muted-foreground" />
                            {subscription.startDate}
                          </div>
                        </td>
                        <td className="py-3 px-4 hidden lg:table-cell">
                          {subscription.endDate !== "N/A" ? (
                            <div className="flex items-center">
                              <Calendar className="h-3.5 w-3.5 mr-1.5 text-muted-foreground" />
                              {subscription.endDate}
                            </div>
                          ) : (
                            "N/A"
                          )}
                        </td>
                        <td className="py-3 px-4 hidden lg:table-cell">
                          <div className="flex items-center">
                            <CreditCard className="h-3.5 w-3.5 mr-1.5 text-muted-foreground" />
                            {subscription.amount}
                            {subscription.billingCycle === "monthly" ? "/mo" : "/yr"}
                          </div>
                        </td>
                        <td className="py-3 px-4 text-right">
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon">
                                <MoreHorizontal className="h-4 w-4" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              <DropdownMenuItem>View Details</DropdownMenuItem>
                              <DropdownMenuItem>Edit Subscription</DropdownMenuItem>
                              {subscription.status === "active" ? (
                                <DropdownMenuItem className="text-destructive">Cancel Subscription</DropdownMenuItem>
                              ) : (
                                <DropdownMenuItem>Reactivate</DropdownMenuItem>
                              )}
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </TabsContent>

            <TabsContent value="active" className="m-0">
              <div className="py-10 text-center text-muted-foreground">
                Switch to the "All Subscriptions" tab and use the status filter for a complete view.
              </div>
            </TabsContent>

            <TabsContent value="expired" className="m-0">
              <div className="py-10 text-center text-muted-foreground">
                Switch to the "All Subscriptions" tab and use the status filter for a complete view.
              </div>
            </TabsContent>

            <TabsContent value="canceled" className="m-0">
              <div className="py-10 text-center text-muted-foreground">
                Switch to the "All Subscriptions" tab and use the status filter for a complete view.
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  )
}
