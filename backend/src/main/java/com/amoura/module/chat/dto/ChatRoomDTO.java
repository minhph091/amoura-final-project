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
public class ChatRoomDTO {
    private Long id;
    private Long user1Id;
    private String user1Name;
    private String user1Avatar;
    private Long user2Id;
    private String user2Name;
    private String user2Avatar;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long unreadCount;
    private MessageDTO lastMessage;
} 