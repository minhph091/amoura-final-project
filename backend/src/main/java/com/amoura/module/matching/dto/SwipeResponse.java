package com.amoura.module.matching.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SwipeResponse {
    private Long swipeId;
    private Boolean isMatch;
    private Long matchId;
    private Long chatRoomId;
    private Long matchedUserId;
    private String matchedUsername;
    private String matchMessage;
} 