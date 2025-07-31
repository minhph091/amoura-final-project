package com.amoura.module.admin.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Cursor-based pagination response")
public class CursorPaginationResponse<T> {
    
    @Schema(description = "List of items")
    private List<T> data;
    
    @Schema(description = "Cursor for the next page (ID of the last item in current page)")
    private Long nextCursor;
    
    @Schema(description = "Cursor for the previous page (ID of the first item in current page)")
    private Long previousCursor;
    
    @Schema(description = "Whether there are more items available")
    private Boolean hasNext;
    
    @Schema(description = "Whether there are previous items available")
    private Boolean hasPrevious;
    
    @Schema(description = "Total number of items in current page")
    private Integer count;
}