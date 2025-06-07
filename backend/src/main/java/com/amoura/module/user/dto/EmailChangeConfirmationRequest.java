package com.amoura.module.user.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class EmailChangeConfirmationRequest {
    @NotBlank(message = "OTP code is required")
    private String otpCode;
} 