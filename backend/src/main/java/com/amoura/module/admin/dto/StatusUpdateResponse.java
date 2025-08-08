package com.amoura.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Response for user status update operation")
public class StatusUpdateResponse {
    
    @Schema(description = "Operation success status", example = "true")
    private boolean success;
    
    @Schema(description = "User ID that was updated", example = "1")
    private Long userId;
    
    @Schema(description = "New status after update", example = "SUSPEND", allowableValues = {"ACTIVE", "INACTIVE", "SUSPEND"})
    private String newStatus;
    
    @Schema(description = "Previous status before update", example = "ACTIVE", allowableValues = {"ACTIVE", "INACTIVE", "SUSPEND"})
    private String previousStatus;
    
    @Schema(description = "Success message", example = "User status updated successfully")
    private String message;
    
    @Schema(description = "Reason for status change", example = "Violated community guidelines")
    private String reason;
}