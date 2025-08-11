package com.amoura.module.matching.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AIPotentialMatchResponse {
    
    @JsonProperty("user_id")
    private Long userId;
    
    @JsonProperty("potential_match_ids")
    private List<Long> potentialMatchIds;
}
