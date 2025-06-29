"use client";

import React, { useState } from "react";
import { useUsers, useUserActions } from "@/src/hooks/useUsers";
import { UserFiltersComponent } from "./UserFilters";
import { UserCard } from "./UserCard";
import { UserDetailsDialog } from "./UserDetailsDialog";
import { UserActionDialog } from "./UserActionDialog";
import { PaginationComponent } from "@/components/common/PaginationComponent";
import {
  ErrorState,
  LoadingState,
  EmptyState,
} from "@/components/common/States";
import { useToast } from "@/hooks/use-toast";
import type { User, UserFilters } from "@/src/types";
import { useLanguage } from "@/src/contexts/LanguageContext";

export function UserManagement() {
  const [filters, setFilters] = useState<UserFilters>({
    page: 1,
    limit: 10,
    sortBy: "fullName",
    sortOrder: "asc",
  });

  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [userDetailsOpen, setUserDetailsOpen] = useState(false);
  const [actionDialogOpen, setActionDialogOpen] = useState(false);
  const [currentAction, setCurrentAction] = useState<"suspend" | "restore">(
    "suspend"
  );

  const { users, pagination, loading, error, refetch } = useUsers(filters);
  const {
    suspendUser,
    restoreUser,
    loading: actionLoading,
    error: actionError,
  } = useUserActions();
  const { toast } = useToast();
  const { t } = useLanguage();

  const handleFiltersChange = (newFilters: UserFilters) => {
    setFilters(newFilters);
  };

  const handlePageChange = (page: number) => {
    setFilters((prev) => ({ ...prev, page }));
  };

  const handleViewUser = (user: User) => {
    setSelectedUser(user);
    setUserDetailsOpen(true);
  };

  const handleSuspendUser = (user: User) => {
    setSelectedUser(user);
    setCurrentAction("suspend");
    setActionDialogOpen(true);
  };

  const handleRestoreUser = (user: User) => {
    setSelectedUser(user);
    setCurrentAction("restore");
    setActionDialogOpen(true);
  };

  const handleConfirmAction = async (reason?: string) => {
    if (!selectedUser) return;

    const success =
      currentAction === "suspend"
        ? await suspendUser(selectedUser.id.toString(), reason)
        : await restoreUser(selectedUser.id.toString());

    if (success) {
      toast({
        title: t.success,
        description: `${t.user} ${
          currentAction === "suspend" ? t.suspendedText : t.restored
        } ${t.successfully}`,
      });
      setActionDialogOpen(false);
      setSelectedUser(null);
      refetch();
    } else if (actionError) {
      toast({
        title: t.error,
        description: actionError,
        variant: "destructive",
      });
    }
  };

  if (error) {
    return <ErrorState error={error} onRetry={refetch} />;
  }

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold tracking-tight">{t.userManagement}</h1>

      <UserFiltersComponent
        filters={filters}
        onFiltersChange={handleFiltersChange}
      />

      {loading ? (
        <LoadingState />
      ) : users.length === 0 ? (
        <EmptyState
          message={t.noUsersFound || "No users found matching your criteria"}
        />
      ) : (
        <div className="space-y-4">
          {users.map((user) => (
            <UserCard
              key={user.id}
              user={user}
              onView={handleViewUser}
              onSuspend={handleSuspendUser}
              onRestore={handleRestoreUser}
            />
          ))}
        </div>
      )}

      {pagination && (
        <PaginationComponent
          pagination={pagination}
          onPageChange={handlePageChange}
        />
      )}

      <UserDetailsDialog
        user={selectedUser}
        open={userDetailsOpen}
        onOpenChange={setUserDetailsOpen}
      />

      <UserActionDialog
        user={selectedUser}
        open={actionDialogOpen}
        onOpenChange={setActionDialogOpen}
        action={currentAction}
        onConfirm={handleConfirmAction}
        loading={actionLoading}
      />
    </div>
  );
}
