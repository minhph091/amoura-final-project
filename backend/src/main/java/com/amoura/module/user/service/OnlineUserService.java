package com.amoura.module.user.service;

import org.springframework.stereotype.Service;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import com.amoura.module.chat.repository.ChatRoomRepository;
import java.util.List;

@Service
public class OnlineUserService {
    private final Set<Long> onlineUsers = ConcurrentHashMap.newKeySet();

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Autowired
    private ChatRoomRepository chatRoomRepository;

    public void userOnline(Long userId) {
        onlineUsers.add(userId);
        broadcastStatusToChatRooms(userId, true);
    }

    public void userOffline(Long userId) {
        onlineUsers.remove(userId);
        broadcastStatusToChatRooms(userId, false);
    }

    public boolean isOnline(Long userId) {
        return onlineUsers.contains(userId);
    }

    public Set<Long> getOnlineUsers() {
        return onlineUsers;
    }

    private void broadcastStatusToChatRooms(Long userId, boolean online) {
        // Lấy danh sách các phòng chat mà user này tham gia
        List<Long> chatRoomIds = chatRoomRepository.findChatRoomIdsByUserId(userId);
        UserStatusMessage msg = new UserStatusMessage(userId, online ? "ONLINE" : "OFFLINE");
        for (Long chatRoomId : chatRoomIds) {
            messagingTemplate.convertAndSend("/topic/chat/" + chatRoomId + "/user-status", msg);
        }
    }

    // DTO cho message trạng thái
    public static class UserStatusMessage {
        public Long userId;
        public String status;
        public UserStatusMessage(Long userId, String status) {
            this.userId = userId;
            this.status = status;
        }
    }
} 