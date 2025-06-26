package com.amoura.common.config;

import com.amoura.infrastructure.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.stereotype.Component;

import java.security.Principal;

@Component
@RequiredArgsConstructor
@Slf4j
public class WebSocketAuthInterceptor implements ChannelInterceptor {

    private final JwtTokenProvider jwtTokenProvider;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
        
        if (accessor != null && StompCommand.CONNECT.equals(accessor.getCommand())) {
            String token = extractToken(accessor);
            
            if (token != null && jwtTokenProvider.validateToken(token)) {
                String username = jwtTokenProvider.getUsername(token);
                Long userId = jwtTokenProvider.getUserId(token);
                
                // Create custom principal for WebSocket
                Principal principal = new Principal() {
                    @Override
                    public String getName() {
                        return userId.toString();
                    }
                };
                
                accessor.setUser(principal);
                
                // Set userId vào session attributes để ChatController có thể lấy được
                accessor.getSessionAttributes().put("userId", userId);
                
                log.info("WebSocket authenticated for user: {} (ID: {})", username, userId);
            } else {
                log.warn("WebSocket authentication failed - invalid token");
            }
        }
        
        return message;
    }

    private String extractToken(StompHeaderAccessor accessor) {
        // Try to get token from Authorization header
        String authHeader = accessor.getFirstNativeHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        
        // Try to get token from query parameter
        String token = accessor.getFirstNativeHeader("token");
        if (token != null) {
            return token;
        }
        
        return null;
    }
} 