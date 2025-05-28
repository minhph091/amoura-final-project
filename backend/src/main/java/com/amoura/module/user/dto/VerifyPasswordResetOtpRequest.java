package com.amoura.module.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotBlank;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VerifyPasswordResetOtpRequest {

    @NotBlank(message = "Session token is required")
    private String sessionToken;

    @NotBlank(message = "OTP code is required")
    private String otpCode;
} 