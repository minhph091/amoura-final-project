package com.amoura.module.chat.service;

import com.amoura.module.chat.dto.ChatRoomDTO;
import com.amoura.module.chat.dto.CursorPaginationRequest;
import com.amoura.module.chat.dto.CursorPaginationResponse;
import com.amoura.module.chat.dto.MessageDTO;
import com.amoura.module.chat.dto.SendMessageRequest;

import java.util.List;

public interface ChatService {
    
    // Chat Room operations
    ChatRoomDTO createOrGetChatRoom(Long userId1, Long userId2);
    List<ChatRoomDTO> getUserChatRooms(Long userId, CursorPaginationRequest request);
    ChatRoomDTO getChatRoomById(Long chatRoomId, Long userId);
    void deactivateChatRoom(Long chatRoomId, Long userId);
    
    // Message operations
    MessageDTO sendMessage(SendMessageRequest request, Long senderId);
    CursorPaginationResponse<MessageDTO> getChatMessages(Long chatRoomId, Long userId, CursorPaginationRequest request);
    void markMessagesAsRead(Long chatRoomId, Long userId);
    Long getUnreadMessageCount(Long chatRoomId, Long userId);
    
    // WebSocket operations
    void sendMessageToChatRoom(Long chatRoomId, MessageDTO message);
    void sendTypingIndicator(Long chatRoomId, Long senderId, boolean isTyping);
    void sendReadReceipt(Long chatRoomId, Long userId);
} 