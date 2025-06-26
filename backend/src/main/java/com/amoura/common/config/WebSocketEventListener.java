package com.amoura.common.config;

import com.amoura.module.user.service.OnlineUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import java.security.Principal;

@Component
@RequiredArgsConstructor
@Slf4j
public class WebSocketEventListener {

    private final OnlineUserService onlineUserService;

    @EventListener
    public void handleSessionConnected(SessionConnectEvent event) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
        Principal user = accessor.getUser();
        if (user != null) {
            try {
                Long userId = Long.parseLong(user.getName());
                onlineUserService.userOnline(userId);
                log.info("User {} is now ONLINE", userId);
            } catch (NumberFormatException ignored) {}
        }
    }

    @EventListener
    public void handleSessionDisconnect(SessionDisconnectEvent event) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
        Principal user = accessor.getUser();
        if (user != null) {
            try {
                Long userId = Long.parseLong(user.getName());
                onlineUserService.userOffline(userId);
                log.info("User {} is now OFFLINE", userId);
            } catch (NumberFormatException ignored) {}
        }
    }
} 