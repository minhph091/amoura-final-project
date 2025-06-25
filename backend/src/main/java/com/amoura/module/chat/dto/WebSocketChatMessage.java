package com.amoura.module.chat.dto;

import com.amoura.module.chat.domain.MessageType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WebSocketChatMessage {
    private String type; // MESSAGE, TYPING, READ_RECEIPT, MESSAGE_RECALLED, etc.
    private Long chatRoomId;
    private Long messageId;
    private Long senderId;
    private String senderName;
    private String senderAvatar;
    private String content;
    private MessageType messageType;
    private LocalDateTime timestamp;
    private Boolean isRead;
    private String imageUrl;
    private Boolean recalled;
    private LocalDateTime recalledAt;
} 