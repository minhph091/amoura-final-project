export interface Match {
  id: string;
  user1: MatchUser;
  user2: MatchUser;
  matchDate: string;
  status: MatchStatus;
  compatibilityScore: number;
  commonInterests: string[];
  lastMessageAt?: string;
  messageCount: number;
}

export interface MatchUser {
  id: string;
  name: string;
  avatar: string;
  initials: string;
  age: number;
  location: string;
}

export type MatchStatus = "active" | "blocked" | "unmatched" | "reported";

export interface CreateMatchRequest {
  user1Id: string;
  user2Id: string;
  compatibilityScore: number;
  commonInterests: string[];
}

export interface MatchFilters {
  search?: string;
  status?: MatchStatus | "all";
  compatibilityRange?: {
    min: number;
    max: number;
  };
  dateRange?: {
    from: Date;
    to: Date;
  };
  hasMessages?: boolean;
  sortBy?: "matchDate" | "compatibilityScore" | "messageCount";
  sortOrder?: "asc" | "desc";
}

export interface MatchStats {
  totalMatches: number;
  activeMatches: number;
  matchesThisMonth: number;
  averageCompatibilityScore: number;
  matchesWithMessages: number;
  averageMessagesPerMatch: number;
}
