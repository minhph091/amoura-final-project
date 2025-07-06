export const API_ENDPOINTS = {
  // Backend Authentication APIs
  AUTH: {
    LOGIN: "/auth/login",
    LOGOUT: "/auth/logout",
    REFRESH: "/auth/refresh",
    PROFILE: "/user", // GET current user info
    CHANGE_PASSWORD: "/user/change-password",
  },
  // Backend User APIs (limited access for admin)
  USERS: {
    LIST: "/users",
    CREATE: "/users",
    GET: (id: string) => `/users/${id}/online`,
    UPDATE: (id: string) => `/user`,
    DELETE: (id: string) => `/users/${id}`,
    SUSPEND: (id: string) => `/users/${id}/suspend`,
    RESTORE: (id: string) => `/users/${id}/restore`,
    STATS: "/users/stats",
  },
  // Backend Profile APIs
  PROFILES: {
    GET: (id: string) => `/profiles/${id}`,
    GET_ME: "/profiles/me",
    UPDATE: "/profiles/me",
    OPTIONS: "/profiles/options",
  },
  // Backend Chat APIs (for admin monitoring)
  CHAT: {
    ROOMS: "/chat/rooms",
    MESSAGES: (roomId: string) => `/chat/rooms/${roomId}/messages`,
    DELETE_MESSAGE: (messageId: string) =>
      `/chat/messages/${messageId}/delete-for-me`,
  },
  // Backend Matching APIs
  MATCHING: {
    RECOMMENDATIONS: "/matching/recommendations",
    SWIPE: "/matching/swipe",
  },
  // Backend Notification APIs
  NOTIFICATIONS: {
    LIST: "/notifications",
    UNREAD: "/notifications/unread",
    UNREAD_COUNT: "/notifications/unread/count",
    MARK_READ: (id: string) => `/notifications/${id}/read`,
    MARK_ALL_READ: "/notifications/read-all",
  },
  ADMIN: {
    USERS: "/admin/users",
    MODERATORS: "/admin/moderators",
    REPORTS: "/admin/reports",
    STATS: "/admin/stats",
  },
} as const;

export const STORAGE_KEYS = {
  AUTH_TOKEN: "auth_token",
  REFRESH_TOKEN: "refresh_token",
  USER_DATA: "user_data",
  SIDEBAR_COLLAPSED: "sidebar_collapsed",
  THEME: "theme",
  PRIMARY_COLOR: "primary_color",
  FONT_SIZE: "font_size",
  ADMIN_AVATAR: "admin_avatar",
} as const;

export const QUERY_KEYS = {
  USERS: ["users"],
  USER: (id: string) => ["users", id],
  PROFILES: ["profiles"],
  PROFILE: (id: string) => ["profiles", id],
  CHAT_ROOMS: ["chat", "rooms"],
  MESSAGES: (roomId: string) => ["chat", "messages", roomId],
  NOTIFICATIONS: ["notifications"],
  MATCHING: ["matching"],
  ADMIN_STATS: ["admin", "stats"],
} as const;
