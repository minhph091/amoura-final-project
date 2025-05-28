package com.amoura.module.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PasswordResetResponse {
    private String sessionToken;
    private String status;
    private String message;
    private Long expiresIn;
} 