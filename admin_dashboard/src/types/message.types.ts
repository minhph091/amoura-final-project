export interface Message {
  id: string;
  sender: MessageUser;
  recipient: MessageUser;
  content: string;
  timestamp: string;
  status: MessageStatus;
  type: MessageType;
  attachments?: MessageAttachment[];
  isRead: boolean;
  readAt?: string;
  editedAt?: string;
  replyTo?: string;
}

export interface MessageUser {
  id: string;
  name: string;
  avatar: string;
  initials: string;
}

export type MessageStatus = "sent" | "delivered" | "read" | "failed";
export type MessageType = "text" | "image" | "gif" | "voice" | "video";

export interface MessageAttachment {
  id: string;
  type: MessageType;
  url: string;
  fileName?: string;
  size?: number;
  duration?: number; // for voice/video
}

export interface CreateMessageRequest {
  senderId: string;
  recipientId: string;
  content: string;
  type: MessageType;
  attachments?: File[];
}

export interface MessageFilters {
  search?: string;
  status?: MessageStatus | "all";
  type?: MessageType | "all";
  senderId?: string;
  recipientId?: string;
  dateRange?: {
    from: Date;
    to: Date;
  };
  sortBy?: "timestamp" | "sender" | "recipient";
  sortOrder?: "asc" | "desc";
}

export interface MessageStats {
  totalMessages: number;
  messagesThisMonth: number;
  averageMessagesPerUser: number;
  messagesByType: Record<MessageType, number>;
  messagesByStatus: Record<MessageStatus, number>;
}
