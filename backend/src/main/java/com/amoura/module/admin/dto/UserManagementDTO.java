package com.amoura.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "User data for admin management")
public class UserManagementDTO {
    
    @Schema(description = "User ID", example = "1")
    private Long id;
    
    @Schema(description = "Username", example = "john_doe")
    private String username;
    
    @Schema(description = "Email address", example = "john@example.com")
    private String email;
    
    @Schema(description = "Phone number", example = "+1234567890")
    private String phoneNumber;
    
    @Schema(description = "First name", example = "John")
    private String firstName;
    
    @Schema(description = "Last name", example = "Doe")
    private String lastName;
    
    @Schema(description = "Full name", example = "John Doe")
    private String fullName;
    
    @Schema(description = "User role name", example = "USER")
    private String roleName;
    
    @Schema(description = "Account status", example = "ACTIVE", allowableValues = {"ACTIVE", "INACTIVE", "SUSPEND"})
    private String status;
    
    @Schema(description = "Last login timestamp")
    private LocalDateTime lastLogin;
    
    @Schema(description = "Account creation timestamp")
    private LocalDateTime createdAt;
    
    @Schema(description = "Last update timestamp")
    private LocalDateTime updatedAt;
    
    @Schema(description = "Profile completion status")
    private Boolean hasProfile;
    
    @Schema(description = "Number of photos uploaded")
    private Integer photoCount;
    
    @Schema(description = "Total matches count")
    private Long totalMatches;
    
    @Schema(description = "Total messages sent")
    private Long totalMessages;
}