package com.amoura.module.chat.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AIMessageEditApiResponse {
    
    @JsonProperty("edited_message")
    private String editedMessage;
    
    @JsonProperty("original_message")
    private String originalMessage;
}
