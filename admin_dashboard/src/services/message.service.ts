import { apiClient } from "./api.service";
import { API_ENDPOINTS } from "../constants/api.constants";
import type { ApiResponse, PaginatedResponse } from "../types/common.types";

// Message types based on backend ChatRoomDTO and MessageDTO
export interface ChatRoom {
  id: number;
  user1Id: number;
  user2Id: number;
  lastMessage?: Message;
  lastMessageAt?: string;
  isActive: boolean;
  unreadCount?: number;
  otherUser?: {
    id: number;
    name: string;
    avatar?: string;
  };
}

export interface Message {
  id: number;
  chatRoomId: number;
  senderId: number;
  receiverId: number;
  content?: string;
  imageUrl?: string;
  messageType: "TEXT" | "IMAGE" | "SYSTEM";
  sentAt: string;
  isRead: boolean;
  isRecalled: boolean;
  senderName?: string;
  senderAvatar?: string;
}

export interface ChatFilters {
  search?: string;
  sortBy?: "lastMessageAt" | "createdAt";
  sortOrder?: "asc" | "desc";
  page?: number;
  limit?: number;
}

export interface MessageStats {
  totalMessages: number;
  textMessages: number;
  imageMessages: number;
  todayMessages: number;
  reportedMessages: number;
}

export class MessageService {
  // Get all chat rooms (for admin monitoring)
  async getChatRooms(
    filters?: ChatFilters
  ): Promise<PaginatedResponse<ChatRoom>> {
    try {
      const params: Record<string, unknown> = {};

      if (filters?.page) params.cursor = filters.page;
      if (filters?.limit) params.limit = filters.limit;
      if (filters?.sortOrder)
        params.direction = filters.sortOrder === "desc" ? "PREV" : "NEXT";

      const response = await apiClient.get<ChatRoom[]>(
        API_ENDPOINTS.CHAT.ROOMS,
        params
      );

      if (response.success && response.data) {
        // Convert to paginated response
        return {
          success: true,
          data: response.data,
          pagination: {
            page: filters?.page || 1,
            limit: filters?.limit || 20,
            total: response.data.length,
            totalPages: Math.ceil(
              response.data.length / (filters?.limit || 20)
            ),
            hasNext: false,
            hasPrev: false,
          },
        };
      }

      return {
        success: false,
        error: response.error || "Failed to fetch chat rooms",
        data: [],
        pagination: {
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 0,
          hasNext: false,
          hasPrev: false,
        },
      };
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to fetch chat rooms",
        data: [],
        pagination: {
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 0,
          hasNext: false,
          hasPrev: false,
        },
      };
    }
  }

  // Get messages in a chat room
  async getMessages(
    chatRoomId: string,
    page = 1,
    limit = 20
  ): Promise<PaginatedResponse<Message>> {
    try {
      const response = await apiClient.get<{
        messages: Message[];
        hasNext: boolean;
        nextCursor?: number;
      }>(API_ENDPOINTS.CHAT.MESSAGES(chatRoomId), {
        cursor: page > 1 ? page : undefined,
        limit,
        direction: "NEXT",
      });

      if (response.success && response.data) {
        return {
          success: true,
          data: response.data.messages || [],
          pagination: {
            page,
            limit,
            total: response.data.messages?.length || 0,
            totalPages: response.data.hasNext ? page + 1 : page,
            hasNext: response.data.hasNext || false,
            hasPrev: page > 1,
          },
        };
      }

      return {
        success: false,
        error: response.error || "Failed to fetch messages",
        data: [],
        pagination: {
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 0,
          hasNext: false,
          hasPrev: false,
        },
      };
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to fetch messages",
        data: [],
        pagination: {
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 0,
          hasNext: false,
          hasPrev: false,
        },
      };
    }
  }

  // Delete message (admin action)
  async deleteMessage(messageId: string): Promise<ApiResponse<void>> {
    try {
      return await apiClient.post<void>(
        API_ENDPOINTS.CHAT.DELETE_MESSAGE(messageId)
      );
    } catch (error) {
      return {
        success: false,
        error:
          error instanceof Error ? error.message : "Failed to delete message",
      };
    }
  }

}

export const messageService = new MessageService();
