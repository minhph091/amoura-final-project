package com.amoura.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Request to update user status")
public class UserStatusUpdateRequest {
    
    @NotBlank(message = "Status is required")
    @Pattern(regexp = "^(ACTIVE|INACTIVE|SUSPEND)$", message = "Status must be ACTIVE, INACTIVE, or SUSPEND")
    @Schema(description = "New status for the user", example = "SUSPEND", allowableValues = {"ACTIVE", "INACTIVE", "SUSPEND"})
    private String status;
    
    @Schema(description = "Reason for status change", example = "Violated community guidelines")
    private String reason;
}