package com.amoura.module.chat.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AIEditMessageRequest {
    
    @NotBlank(message = "Original message is required")
    @Size(max = 2000, message = "Original message cannot exceed 2000 characters")
    private String originalMessage;
    
    @NotBlank(message = "Edit prompt is required")
    @Size(max = 500, message = "Edit prompt cannot exceed 500 characters")
    private String editPrompt;
    
    @NotNull(message = "Receiver ID is required")
    private Long receiverId;
}
