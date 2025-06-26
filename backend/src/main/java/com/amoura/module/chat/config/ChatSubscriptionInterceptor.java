package com.amoura.module.chat.config;

import com.amoura.module.chat.repository.ChatRoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Component;

import java.security.Principal;

@Component
@RequiredArgsConstructor
public class ChatSubscriptionInterceptor implements ChannelInterceptor {

    private final ChatRoomRepository chatRoomRepository;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(message);

        if (StompCommand.SUBSCRIBE.equals(accessor.getCommand())) {
            String destination = accessor.getDestination(); // ví dụ: /topic/chat/123/user-status
            Principal user = accessor.getUser();
            if (destination != null && destination.startsWith("/topic/chat/")) {
                Long chatRoomId = extractChatRoomId(destination);
                Long userId = Long.parseLong(user.getName());
                if (!chatRoomRepository.isUserInChatRoom(chatRoomId, userId)) {
                    throw new AccessDeniedException("You are not allowed to subscribe to this chat room");
                }
            }
        }
        return message;
    }

    private Long extractChatRoomId(String destination) {
        // Parse chatRoomId từ chuỗi, ví dụ: /topic/chat/123/user-status
        String[] parts = destination.split("/");
        return Long.parseLong(parts[3]);
    }
} 