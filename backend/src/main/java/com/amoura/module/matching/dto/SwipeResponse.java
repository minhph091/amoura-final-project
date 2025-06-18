package com.amoura.module.matching.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SwipeResponse {
    private Long swipeId;
    private Boolean isMatch;
    private Long messageId;
    private String matchMessage;
} 