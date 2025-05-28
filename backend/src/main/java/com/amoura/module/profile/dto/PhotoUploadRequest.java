package com.amoura.module.profile.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PhotoUploadRequest {
    @NotNull(message = "Photo type is required")
    private String type; // avatar, profile_cover, highlight
} 