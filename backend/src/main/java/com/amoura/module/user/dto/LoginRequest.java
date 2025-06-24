package com.amoura.module.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Email;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequest {

    // Email hoặc phone
    @Email(message = "Invalid email format")
    private String email;
    private String phoneNumber;

    // Password hoặc OTP
    private String password;
    private String otpCode;

    // Login type
    @NotBlank(message = "Login type is required")
    private String loginType; // EMAIL_PASSWORD, PHONE_PASSWORD, EMAIL_OTP
}