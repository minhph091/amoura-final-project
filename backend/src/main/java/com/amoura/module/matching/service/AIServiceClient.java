package com.amoura.module.matching.service;

import com.amoura.module.matching.dto.AIPotentialMatchResponse;
import com.amoura.module.chat.dto.AIEditMessageRequest;
import com.amoura.module.chat.dto.AIEditMessageResponse;
import com.amoura.module.chat.dto.AIMessageEditApiRequest;
import com.amoura.module.chat.dto.AIMessageEditApiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;

import java.util.Collections;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class AIServiceClient {

    private final RestTemplate restTemplate;

    @Value("${ai.service.base-url}")
    private String aiServiceBaseUrl;


    public List<Long> getPotentialMatches(Long userId, int limit) {
        try {
            log.info("Calling AI service for user {} with limit {}", userId, limit);
            
            String url = String.format("%s/api/v1/users/%d/matches?limit=%d", 
                    aiServiceBaseUrl, userId, limit);
            
            AIPotentialMatchResponse response = restTemplate.getForObject(url, AIPotentialMatchResponse.class);
            
            if (response != null && response.getPotentialMatchIds() != null) {
                log.info("AI service returned {} potential matches for user {}", 
                        response.getPotentialMatchIds().size(), userId);
                return response.getPotentialMatchIds();
            } else {
                log.warn("AI service returned null or empty response for user {}", userId);
                return Collections.emptyList();
            }
            
        } catch (HttpClientErrorException e) {
            if (e.getStatusCode() == HttpStatus.NOT_FOUND) {
                log.warn("User {} not found in AI service", userId);
            } else {
                log.error("HTTP client error calling AI service for user {}: {} - {}", 
                        userId, e.getStatusCode(), e.getMessage());
            }
            return Collections.emptyList();
            
        } catch (HttpServerErrorException e) {
            log.error("HTTP server error calling AI service for user {}: {} - {}", 
                    userId, e.getStatusCode(), e.getMessage());
            return Collections.emptyList();
            
        } catch (ResourceAccessException e) {
            log.error("Connection error calling AI service for user {}: {}", userId, e.getMessage());
            return Collections.emptyList();
            
        } catch (Exception e) {
            log.error("Unexpected error calling AI service for user {}: {}", userId, e.getMessage(), e);
            return Collections.emptyList();
        }
    }


    public AIEditMessageResponse editMessage(AIEditMessageRequest request, Long senderId) {
        try {
            
            // Prepare request body for AI service
            AIMessageEditApiRequest apiRequest = AIMessageEditApiRequest.builder()
                    .originalMessage(request.getOriginalMessage())
                    .editPrompt(request.getEditPrompt())
                    .senderId(senderId)
                    .receiverId(request.getReceiverId())
                    .build();
            
            // Set headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            HttpEntity<AIMessageEditApiRequest> entity = new HttpEntity<>(apiRequest, headers);
            
            String url = aiServiceBaseUrl + "/api/v1/messages/edit";
            
            ResponseEntity<AIMessageEditApiResponse> response = restTemplate.exchange(
                    url, 
                    HttpMethod.POST, 
                    entity, 
                    AIMessageEditApiResponse.class
            );
            
            if (response.getBody() != null) {
                AIMessageEditApiResponse apiResponse = response.getBody();
                
                return AIEditMessageResponse.builder()
                        .editedMessage(apiResponse.getEditedMessage())
                        .originalMessage(apiResponse.getOriginalMessage())
                        .build();
            } else {
                log.warn("AI service returned null response for message edit");
                return createFallbackResponse(request.getOriginalMessage());
            }
            
        } catch (HttpClientErrorException e) {
            log.error("HTTP client error calling AI service for message edit: {} - {}", 
                    e.getStatusCode(), e.getMessage());
            return createFallbackResponse(request.getOriginalMessage());
            
        } catch (HttpServerErrorException e) {
            log.error("HTTP server error calling AI service for message edit: {} - {}", 
                    e.getStatusCode(), e.getMessage());
            return createFallbackResponse(request.getOriginalMessage());
            
        } catch (ResourceAccessException e) {
            log.error("Connection error calling AI service for message edit: {}", e.getMessage());
            return createFallbackResponse(request.getOriginalMessage());
            
        } catch (Exception e) {
            log.error("Unexpected error calling AI service for message edit: {}", e.getMessage(), e);
            return createFallbackResponse(request.getOriginalMessage());
        }
    }

    private AIEditMessageResponse createFallbackResponse(String originalMessage) {
        return AIEditMessageResponse.builder()
                .editedMessage(originalMessage) // Return original message as fallback
                .originalMessage(originalMessage)
                .build();
    }


    public boolean isAIServiceAvailable() {
        try {
            String url = aiServiceBaseUrl + "/health";
            restTemplate.getForObject(url, String.class);
            return true;
        } catch (Exception e) {
            log.warn("AI service health check failed: {}", e.getMessage());
            return false;
        }
    }
}
