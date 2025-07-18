package com.amoura.module.notification.dto;

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
    
    @Schema(description = "Cursor for pagination (ID of the last item from previous page)", example = "123")
    private Long cursor;
    
    @Schema(description = "Number of items to fetch", example = "20", defaultValue = "20")
    private Integer limit = 20;
    
    @Schema(description = "Direction of pagination", example = "NEXT", allowableValues = {"NEXT", "PREVIOUS"}, defaultValue = "NEXT")
    private String direction = "NEXT";
} 