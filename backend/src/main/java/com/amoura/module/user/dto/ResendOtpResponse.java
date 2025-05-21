package com.amoura.module.user.dto;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ResendOtpResponse {
    private String message;
    private Long nextResendAvailableInSeconds;
}