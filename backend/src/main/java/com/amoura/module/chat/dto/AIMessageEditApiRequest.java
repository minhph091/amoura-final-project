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
public class AIMessageEditApiRequest {
    
    @JsonProperty("original_message")
    private String originalMessage;
    
    @JsonProperty("edit_prompt")
    private String editPrompt;
    
    @JsonProperty("sender_id")
    private Long senderId;
    
    @JsonProperty("receiver_id")
    private Long receiverId;
}
