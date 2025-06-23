package com.amoura.module.chat.service;

import com.amoura.common.exception.ApiException;
import com.amoura.module.chat.domain.ChatRoom;
import com.amoura.module.chat.domain.Message;
import com.amoura.module.chat.domain.MessageType;
import com.amoura.module.chat.dto.*;
import com.amoura.module.chat.mapper.ChatMapper;
import com.amoura.module.chat.repository.ChatRoomRepository;
import com.amoura.module.chat.repository.MessageRepository;
import com.amoura.module.chat.repository.UserMessageVisibilityRepository;
import com.amoura.module.user.domain.User;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ChatServiceImpl implements ChatService {

    private final ChatRoomRepository chatRoomRepository;
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final ChatMapper chatMapper;
    private final SimpMessagingTemplate messagingTemplate;
    private final UserMessageVisibilityRepository userMessageVisibilityRepository;

    @Override
    public ChatRoomDTO createOrGetChatRoom(Long userId1, Long userId2) {
        Optional<ChatRoom> existingChatRoom = chatRoomRepository.findByUsers(userId1, userId2);
        
        if (existingChatRoom.isPresent()) {
            ChatRoom chatRoom = existingChatRoom.get();
            if (!chatRoom.getIsActive()) {
                chatRoom.setIsActive(true);
                chatRoom = chatRoomRepository.save(chatRoom);
            }
            return chatMapper.toChatRoomDTO(chatRoom);
        }

        User user1 = userRepository.findById(userId1)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User 1 not found"));
        User user2 = userRepository.findById(userId2)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User 2 not found"));

        ChatRoom newChatRoom = ChatRoom.builder()
                .user1(user1)
                .user2(user2)
                .isActive(true)
                .build();

        ChatRoom savedChatRoom = chatRoomRepository.save(newChatRoom);
        return chatMapper.toChatRoomDTO(savedChatRoom);
    }

    @Override
    public List<ChatRoomDTO> getUserChatRooms(Long userId, CursorPaginationRequest request) {
        Pageable pageable = PageRequest.of(0, request.getLimit());
        List<ChatRoom> chatRooms = chatRoomRepository.findByUserIdOrderByUpdatedAtDesc(userId, pageable);
        return chatMapper.toChatRoomDTOList(chatRooms);
    }

    @Override
    public ChatRoomDTO getChatRoomById(Long chatRoomId, Long userId) {
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Chat room not found"));

        if (!chatRoom.getUser1().getId().equals(userId) && !chatRoom.getUser2().getId().equals(userId)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Access denied to this chat room");
        }

        return chatMapper.toChatRoomDTO(chatRoom);
    }

    @Override
    public void deactivateChatRoom(Long chatRoomId, Long userId) {
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Chat room not found"));

        if (!chatRoom.getUser1().getId().equals(userId) && !chatRoom.getUser2().getId().equals(userId)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Access denied to this chat room");
        }

        chatRoom.setIsActive(false);
        chatRoomRepository.save(chatRoom);
    }

    @Override
    public MessageDTO sendMessage(SendMessageRequest request, Long senderId) {
        ChatRoom chatRoom = chatRoomRepository.findById(request.getChatRoomId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Chat room not found"));

        if (!chatRoom.getUser1().getId().equals(senderId) && !chatRoom.getUser2().getId().equals(senderId)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Access denied to this chat room");
        }

        User sender = userRepository.findById(senderId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Sender not found"));

        Message message = Message.builder()
                .chatRoom(chatRoom)
                .sender(sender)
                .content(request.getContent())
                .messageType(request.getMessageType())
                .isRead(false)
                .imageUrl(request.getImageUrl())
                .imageUploaderId(request.getImageUrl() != null ? senderId : null)
                .build();

        Message savedMessage = messageRepository.save(message);
        
        chatRoom.setUpdatedAt(LocalDateTime.now());
        chatRoomRepository.save(chatRoom);

        MessageDTO messageDTO = chatMapper.toMessageDTO(savedMessage);
        sendMessageToChatRoom(chatRoom.getId(), messageDTO);
        
        return messageDTO;
    }

    @Override
    public CursorPaginationResponse<MessageDTO> getChatMessages(Long chatRoomId, Long userId, CursorPaginationRequest request) {
        Pageable pageable = PageRequest.of(0, request.getLimit());
        List<Message> messages = messageRepository.findVisibleMessagesForUser(chatRoomId, userId, pageable);
        List<MessageDTO> messageDTOs = messages.stream().map(msg -> {
            MessageDTO dto = chatMapper.toMessageDTO(msg);
            return dto;
        }).toList();
        return CursorPaginationResponse.<MessageDTO>builder()
                .data(messageDTOs)
                .nextCursor(null)
                .previousCursor(null)
                .hasNext(false)
                .hasPrevious(false)
                .totalCount(messageDTOs.size())
                .build();
    }

    @Override
    public void markMessagesAsRead(Long chatRoomId, Long userId) {
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Chat room not found"));

        if (!chatRoom.getUser1().getId().equals(userId) && !chatRoom.getUser2().getId().equals(userId)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Access denied to this chat room");
        }

        messageRepository.markMessagesAsRead(chatRoomId, userId, LocalDateTime.now());
        sendReadReceipt(chatRoomId, userId);
    }

    @Override
    public Long getUnreadMessageCount(Long chatRoomId, Long userId) {
        return messageRepository.countUnreadMessagesByChatRoomIdAndUserId(chatRoomId, userId);
    }

    @Override
    public void sendMessageToChatRoom(Long chatRoomId, MessageDTO message) {
        WebSocketChatMessage wsMessage = WebSocketChatMessage.builder()
                .type("MESSAGE")
                .chatRoomId(chatRoomId)
                .messageId(message.getId())
                .senderId(message.getSenderId())
                .senderName(message.getSenderName())
                .senderAvatar(message.getSenderAvatar())
                .content(message.getContent())
                .messageType(message.getMessageType())
                .timestamp(message.getCreatedAt())
                .isRead(message.getIsRead())
                .imageUrl(message.getImageUrl())
                .build();

        messagingTemplate.convertAndSend("/topic/chat/" + chatRoomId, wsMessage);
    }

    @Override
    public void sendTypingIndicator(Long chatRoomId, Long senderId, boolean isTyping) {
        WebSocketChatMessage wsMessage = WebSocketChatMessage.builder()
                .type("TYPING")
                .chatRoomId(chatRoomId)
                .senderId(senderId)
                .timestamp(LocalDateTime.now())
                .build();

        messagingTemplate.convertAndSend("/topic/chat/" + chatRoomId, wsMessage);
    }

    @Override
    public void sendReadReceipt(Long chatRoomId, Long userId) {
        WebSocketChatMessage wsMessage = WebSocketChatMessage.builder()
                .type("READ_RECEIPT")
                .chatRoomId(chatRoomId)
                .senderId(userId)
                .timestamp(LocalDateTime.now())
                .build();

        messagingTemplate.convertAndSend("/topic/chat/" + chatRoomId, wsMessage);
    }
} 