export const ROUTES = {
  HOME: "/",
  LOGIN: "/login",
  DASHBOARD: "/dashboard",
  USERS: "/dashboard/users",
  MODERATORS: "/dashboard/moderators",
  REPORTS: "/dashboard/reports",
  MESSAGES: "/dashboard/messages",
  MATCHES: "/dashboard/matches",
  SUBSCRIPTIONS: "/dashboard/subscriptions",
  PROFILE: "/dashboard/profile",
  SETTINGS: "/dashboard/settings",
  SETTINGS_GENERAL: "/dashboard/settings/general",
  SETTINGS_SECURITY: "/dashboard/settings/security",
  SETTINGS_NOTIFICATIONS: "/dashboard/settings/notifications",
  SETTINGS_APPEARANCE: "/dashboard/settings/appearance",
} as const;

export const NAVIGATION_ITEMS = [
  {
    href: ROUTES.DASHBOARD,
    title: "Dashboard",
    icon: "LayoutDashboard",
  },
  {
    href: ROUTES.USERS,
    title: "Users",
    icon: "Users",
  },
  {
    href: ROUTES.MODERATORS,
    title: "Moderators",
    icon: "ShieldAlert",
  },
  {
    href: ROUTES.REPORTS,
    title: "Reports",
    icon: "Flag",
  },
  {
    href: ROUTES.MATCHES,
    title: "Matches",
    icon: "Heart",
  },
  {
    href: ROUTES.SUBSCRIPTIONS,
    title: "Subscriptions",
    icon: "Crown",
  },
] as const;

export const PAGINATION_DEFAULTS = {
  PAGE: 1,
  LIMIT: 10,
  MAX_LIMIT: 100,
} as const;

export const BREAKPOINTS = {
  MOBILE: 768,
  TABLET: 1024,
  DESKTOP: 1280,
} as const;

export const THEME_COLORS = {
  PRIMARY: "#e11d48",
  SECONDARY: "#64748b",
  SUCCESS: "#10b981",
  WARNING: "#f59e0b",
  ERROR: "#ef4444",
  INFO: "#3b82f6",
} as const;
