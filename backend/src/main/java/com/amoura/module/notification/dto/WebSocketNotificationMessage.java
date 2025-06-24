package com.amoura.module.notification.dto;

import com.amoura.module.notification.domain.NotificationType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WebSocketNotificationMessage {
    private String id;
    private NotificationType type;
    private String title;
    private String content;
    private Long relatedEntityId;
    private String relatedEntityType;
    private LocalDateTime timestamp;
    private String action; // "CREATE", "UPDATE", "DELETE"
} 