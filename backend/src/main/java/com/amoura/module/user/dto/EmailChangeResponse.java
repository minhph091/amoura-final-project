package com.amoura.module.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmailChangeResponse {
    private String message;
    private LocalDateTime nextRequestTime;
    private long remainingSeconds;
} 