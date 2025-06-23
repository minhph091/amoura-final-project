package com.amoura.module.chat.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CursorPaginationResponse<T> {
    private List<T> data;
    private Long nextCursor;
    private Long previousCursor;
    private Boolean hasNext;
    private Boolean hasPrevious;
    private Integer totalCount;
} 