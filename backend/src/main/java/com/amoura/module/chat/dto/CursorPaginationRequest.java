package com.amoura.module.chat.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CursorPaginationRequest {
    private Long cursor;
    private Integer limit = 20;
    private String direction = "NEXT"; // NEXT, PREVIOUS
} 