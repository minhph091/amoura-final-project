package com.amoura.common.config;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;
import com.amoura.module.chat.config.ChatSubscriptionInterceptor;

@Configuration
@EnableWebSocketMessageBroker
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Value("${app.websocket.endpoint}")
    private String websocketEndpoint;

    @Value("${app.websocket.allowed-origins}")
    private String[] allowedOrigins;

    private final WebSocketAuthInterceptor webSocketAuthInterceptor;
    private final ChatSubscriptionInterceptor chatSubscriptionInterceptor;

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // Main WebSocket endpoint
        registry.addEndpoint(websocketEndpoint)
                .setAllowedOriginPatterns("*") // Cho phép tất cả origins trong dev
                .withSockJS();
        
        // Alternative endpoint without SockJS (for native WebSocket)
        registry.addEndpoint(websocketEndpoint)
                .setAllowedOriginPatterns("*");
        
        // Additional endpoint for websocket
        registry.addEndpoint("/websocket")
                .setAllowedOriginPatterns("*")
                .withSockJS();
        
        registry.addEndpoint("/websocket")
                .setAllowedOriginPatterns("*");
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // Enable simple broker for sending messages to clients
        registry.enableSimpleBroker("/topic", "/queue", "/chat", "/notification");
        
        // Set prefix for client-to-server messages
        registry.setApplicationDestinationPrefixes("/app");
        
        // Set prefix for user-specific messages
        registry.setUserDestinationPrefix("/user");
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(webSocketAuthInterceptor, chatSubscriptionInterceptor);
    }
} 