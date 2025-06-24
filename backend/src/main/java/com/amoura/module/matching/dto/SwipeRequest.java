package com.amoura.module.matching.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SwipeRequest {
    
    @NotNull(message = "Target user ID is required")
    private Long targetUserId;
    
    @NotNull(message = "Like status is required")
    private Boolean isLike;
} 