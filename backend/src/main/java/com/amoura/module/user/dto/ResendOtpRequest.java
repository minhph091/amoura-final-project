package com.amoura.module.user.dto;
import lombok.Data;
import jakarta.validation.constraints.NotBlank;

@Data
public class ResendOtpRequest {
    @NotBlank(message = "Session token cannot be blank")
    private String sessionToken;
}