import { useState, useEffect } from "react";
import { userService } from "../services/user.service";
import type { User, UserFilters, UserStats, PaginatedResponse } from "../types";

export function useUsers(filters?: UserFilters) {
  const [data, setData] = useState<PaginatedResponse<User> | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await userService.getUsers(filters);

      if (response.success) {
        setData(response);
      } else {
        setError(response.error || "Failed to fetch users");
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unknown error");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, [JSON.stringify(filters)]);

  const refetch = () => {
    fetchUsers();
  };

  return {
    users: data?.data || [],
    pagination: data?.pagination,
    loading,
    error,
    refetch,
  };
}

export function useUser(id: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await userService.getUser(id);

        if (response.success && response.data) {
          setUser(response.data);
        } else {
          setError(response.error || "Failed to fetch user");
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : "Unknown error");
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchUser();
    }
  }, [id]);

  return { user, loading, error };
}

export function useUserStats() {
  const [stats, setStats] = useState<UserStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await userService.getUserStats();

        if (response.success && response.data) {
          setStats(response.data);
        } else {
          setError(response.error || "Failed to fetch user stats");
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : "Unknown error");
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  return { stats, loading, error };
}

export function useUserActions() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const suspendUser = async (id: string, reason?: string) => {
    try {
      setLoading(true);
      setError(null);
      const response = await userService.suspendUser(id, reason);

      if (!response.success) {
        setError(response.error || "Failed to suspend user");
        return false;
      }

      return true;
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unknown error");
      return false;
    } finally {
      setLoading(false);
    }
  };

  const restoreUser = async (id: string) => {
    try {
      setLoading(true);
      setError(null);
      const response = await userService.restoreUser(id);

      if (!response.success) {
        setError(response.error || "Failed to restore user");
        return false;
      }

      return true;
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unknown error");
      return false;
    } finally {
      setLoading(false);
    }
  };

  const deleteUser = async (id: string) => {
    try {
      setLoading(true);
      setError(null);
      const response = await userService.deleteUser(id);

      if (!response.success) {
        setError(response.error || "Failed to delete user");
        return false;
      }

      return true;
    } catch (err) {
      setError(err instanceof Error ? err.message : "Unknown error");
      return false;
    } finally {
      setLoading(false);
    }
  };

  return {
    suspendUser,
    restoreUser,
    deleteUser,
    loading,
    error,
  };
}
