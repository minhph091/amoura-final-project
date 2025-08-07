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
@Schema(description = "Cursor-based pagination request")
public class CursorPaginationRequest {
    
    @Schema(description = "Cursor for pagination (ID to start from)", example = "123")
    private Long cursor;
    
    @Schema(description = "Number of items to fetch", example = "20", defaultValue = "20")
    @Builder.Default
    private Integer limit = 20;
    
    @Schema(description = "Direction of pagination: NEXT = forward to newer users, PREVIOUS = backward to older users", 
            example = "NEXT", allowableValues = {"NEXT", "PREVIOUS"}, defaultValue = "NEXT")
    @Builder.Default
    private String direction = "NEXT";
}