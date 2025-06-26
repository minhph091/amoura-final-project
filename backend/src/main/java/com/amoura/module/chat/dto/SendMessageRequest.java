package com.amoura.module.chat.dto;

import com.amoura.module.chat.domain.MessageType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SendMessageRequest {
    
    @NotNull(message = "Chat room ID is required")
    private Long chatRoomId;
    
    @NotBlank(message = "Message content is required")
    private String content;
    
    @NotNull(message = "Message type is required")
    private MessageType messageType = MessageType.TEXT;
    
    private String imageUrl; // optional, for image message
} 