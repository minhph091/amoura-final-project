package com.amoura.module.chat.mapper;

import com.amoura.module.chat.domain.ChatRoom;
import com.amoura.module.chat.domain.Message;
import com.amoura.module.chat.dto.ChatRoomDTO;
import com.amoura.module.chat.dto.MessageDTO;
import com.amoura.module.profile.service.PhotoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
public class ChatMapper {
    private final PhotoService photoService;
    @Value("${file.storage.local.base-url}")
    private String baseUrl;

    @Autowired
    public ChatMapper(PhotoService photoService) {
        this.photoService = photoService;
    }
    
    public ChatRoomDTO toChatRoomDTO(ChatRoom chatRoom) {
        if (chatRoom == null) {
            return null;
        }
        
        MessageDTO lastMessage = null;
        if (chatRoom.getMessages() != null && !chatRoom.getMessages().isEmpty()) {
            Message lastMsg = chatRoom.getMessages().stream()
                    .max((m1, m2) -> m1.getCreatedAt().compareTo(m2.getCreatedAt()))
                    .orElse(null);
            if (lastMsg != null) {
                lastMessage = toMessageDTO(lastMsg);
            }
        }
        
        String user1Avatar = null;
        if (chatRoom.getUser1() != null) {
            var avatar = photoService.getUserAvatarById(chatRoom.getUser1().getId());
            user1Avatar = avatar != null ? avatar.getUrl() : null;
        }
        String user2Avatar = null;
        if (chatRoom.getUser2() != null) {
            var avatar = photoService.getUserAvatarById(chatRoom.getUser2().getId());
            user2Avatar = avatar != null ? avatar.getUrl() : null;
        }
        
        return ChatRoomDTO.builder()
                .id(chatRoom.getId())
                .user1Id(chatRoom.getUser1() != null ? chatRoom.getUser1().getId() : null)
                .user1Name(chatRoom.getUser1() != null ? chatRoom.getUser1().getFullName() : null)
                .user1Avatar(user1Avatar)
                .user2Id(chatRoom.getUser2() != null ? chatRoom.getUser2().getId() : null)
                .user2Name(chatRoom.getUser2() != null ? chatRoom.getUser2().getFullName() : null)
                .user2Avatar(user2Avatar)
                .isActive(chatRoom.getIsActive())
                .createdAt(chatRoom.getCreatedAt())
                .updatedAt(chatRoom.getUpdatedAt())
                .lastMessage(lastMessage)
                .build();
    }
    
    public List<ChatRoomDTO> toChatRoomDTOList(List<ChatRoom> chatRooms) {
        if (chatRooms == null) {
            return null;
        }
        return chatRooms.stream()
                .map(this::toChatRoomDTO)
                .collect(Collectors.toList());
    }
    
    public MessageDTO toMessageDTO(Message message) {
        if (message == null) {
            return null;
        }
        
        String senderAvatar = null;
        if (message.getSender() != null) {
            var avatar = photoService.getUserAvatarById(message.getSender().getId());
            senderAvatar = avatar != null ? avatar.getUrl() : null;
        }
        String imageUrl = null;
        if (message.getImageUrl() != null && !message.getImageUrl().isEmpty()) {
            if (message.getImageUrl().startsWith("http")) {
                imageUrl = message.getImageUrl();
            } else {
                imageUrl = baseUrl + "/" + message.getImageUrl();
            }
        }
        
        return MessageDTO.builder()
                .id(message.getId())
                .chatRoomId(message.getChatRoom() != null ? message.getChatRoom().getId() : null)
                .senderId(message.getSender() != null ? message.getSender().getId() : null)
                .senderName(message.getSender() != null ? message.getSender().getFullName() : null)
                .senderAvatar(senderAvatar)
                .content(message.getContent())
                .messageType(message.getMessageType())
                .isRead(message.getIsRead())
                .readAt(message.getReadAt())
                .createdAt(message.getCreatedAt())
                .updatedAt(message.getUpdatedAt())
                .imageUrl(imageUrl)
                .imageUploaderId(message.getImageUploaderId())
                .recalled(message.getRecalled() != null ? message.getRecalled() : false)
                .recalledAt(message.getRecalledAt())
                .build();
    }
    
    public List<MessageDTO> toMessageDTOList(List<Message> messages) {
        if (messages == null) {
            return null;
        }
        return messages.stream()
                .map(this::toMessageDTO)
                .collect(Collectors.toList());
    }
} 