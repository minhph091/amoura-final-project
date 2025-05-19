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
public class LoginRequest {

    // Email hoặc phone
    private String email;
    private String phoneNumber;

    // Password hoặc OTP
    private String password;
    private String otpCode;

    // Login type
    @NotBlank(message = "Login type is required")
    private String loginType; // EMAIL_PASSWORD, PHONE_PASSWORD, EMAIL_OTP
}