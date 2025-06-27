package com.amoura.module.chat.domain;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_message_visibilities")
@Data
@NoArgsConstructor
@AllArgsConstructor
@IdClass(UserMessageVisibility.UserMessageVisibilityId.class)
public class UserMessageVisibility implements Serializable {
    @Id
    private Long userId;
    @Id
    private Long messageId;
    private LocalDateTime deletedForUserAt;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserMessageVisibilityId implements Serializable {
        private Long userId;
        private Long messageId;
    }
} 