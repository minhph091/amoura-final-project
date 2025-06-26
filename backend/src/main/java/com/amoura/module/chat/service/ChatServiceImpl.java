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

import static java.rmi.server.LogStream.log;

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
        // For now, we'll use simple pagination since ChatRoom doesn't have cursor-based pagination implemented
        // In a real implementation, you might want to add cursor-based pagination for chat rooms
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
        // Validate message type and content
        switch (request.getMessageType()) {
            case TEXT:
                if (request.getContent() == null || request.getContent().trim().isEmpty()) {
                    throw new ApiException(HttpStatus.BAD_REQUEST, "Text message must have content");
                }
                if (request.getImageUrl() != null) {
                    throw new ApiException(HttpStatus.BAD_REQUEST, "Text message should not have imageUrl");
                }
                break;
            case IMAGE:
                if (request.getImageUrl() == null || request.getImageUrl().trim().isEmpty()) {
                    throw new ApiException(HttpStatus.BAD_REQUEST, "Image message must have imageUrl");
                }
                break;
            case AUDIO:
            case VIDEO:
            case FILE:
                if (request.getImageUrl() == null || request.getImageUrl().trim().isEmpty()) {
                    throw new ApiException(HttpStatus.BAD_REQUEST, "This message type must have a file url (imageUrl)");
                }
                break;
            case EMOJI:
                if (request.getContent() == null || request.getContent().trim().isEmpty()) {
                    throw new ApiException(HttpStatus.BAD_REQUEST, "Emoji message must have content (emoji code)");
                }
                break;
            case SYSTEM:
                throw new ApiException(HttpStatus.FORBIDDEN, "User cannot send system message");
        }

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
                .imageUrl(request.getImageUrl() != null && request.getImageUrl().startsWith("http")
                    ? request.getImageUrl().substring(request.getImageUrl().indexOf("/chat/"))
                    : request.getImageUrl())
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
        // Validate chat room access
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Chat room not found"));

        if (!chatRoom.getUser1().getId().equals(userId) && !chatRoom.getUser2().getId().equals(userId)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Access denied to this chat room");
        }

        List<Message> messages;
        Long nextCursor = null;
        Long previousCursor = null;
        boolean hasNext = false;
        boolean hasPrevious = false;

        if (request.getCursor() == null) {
            // First page - get latest messages
            messages = messageRepository.findVisibleMessagesForUser(chatRoomId, userId, 
                    PageRequest.of(0, request.getLimit() + 1)); // +1 to check if there are more
            
            if (messages.size() > request.getLimit()) {
                hasNext = true;
                messages = messages.subList(0, request.getLimit());
            }
            
            if (!messages.isEmpty()) {
                nextCursor = messages.get(messages.size() - 1).getId();
            }
        } else {
            // Subsequent pages
            if ("NEXT".equalsIgnoreCase(request.getDirection())) {
                // Get messages before cursor (older messages)
                messages = messageRepository.findByChatRoomIdAndCursorOrderByCreatedAtDesc(
                        chatRoomId, request.getCursor(), userId,
                        PageRequest.of(0, request.getLimit() + 1));
                
                if (messages.size() > request.getLimit()) {
                    hasNext = true;
                    messages = messages.subList(0, request.getLimit());
                }
                
                if (!messages.isEmpty()) {
                    nextCursor = messages.get(messages.size() - 1).getId();
                    previousCursor = messages.get(0).getId();
                }
            } else {
                // Get messages after cursor (newer messages)
                messages = messageRepository.findByChatRoomIdAndCursorOrderByCreatedAtAsc(
                        chatRoomId, request.getCursor(), userId,
                        PageRequest.of(0, request.getLimit() + 1));
                
                if (messages.size() > request.getLimit()) {
                    hasPrevious = true;
                    messages = messages.subList(0, request.getLimit());
                }
                
                if (!messages.isEmpty()) {
                    nextCursor = messages.get(messages.size() - 1).getId();
                    previousCursor = messages.get(0).getId();
                }
            }
        }

        List<MessageDTO> messageDTOs = messages.stream()
                .map(chatMapper::toMessageDTO)
                .toList();

        return CursorPaginationResponse.<MessageDTO>builder()
                .data(messageDTOs)
                .nextCursor(nextCursor)
                .previousCursor(previousCursor)
                .hasNext(hasNext)
                .hasPrevious(hasPrevious)
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
    public void recallMessage(Long messageId, Long userId) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Message not found"));

        if (!message.getSender().getId().equals(userId)) {
            throw new ApiException(HttpStatus.FORBIDDEN, "You can only recall your own messages");
        }

        if (message.getCreatedAt().isBefore(LocalDateTime.now().minusMinutes(30))) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Messages can only be recalled within 30 minutes");
        }

        message.setRecalled(true);
        message.setRecalledAt(LocalDateTime.now());
        messageRepository.save(message);

        // Send WebSocket notification to all users in the chat room
        sendMessageRecalledNotification(message.getChatRoom().getId(), messageId, userId);
    }

    @Override
    public void sendMessageRecalledNotification(Long chatRoomId, Long messageId, Long senderId) {
        WebSocketChatMessage wsMessage = WebSocketChatMessage.builder()
                .type("MESSAGE_RECALLED")
                .chatRoomId(chatRoomId)
                .messageId(messageId)
                .senderId(senderId)
                .timestamp(LocalDateTime.now())
                .recalled(true)
                .recalledAt(LocalDateTime.now())
                .build();

        messagingTemplate.convertAndSend("/topic/chat/" + chatRoomId, wsMessage);
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
                .recalled(message.getRecalled())
                .recalledAt(message.getRecalledAt())
                .build();

        messagingTemplate.convertAndSend("/topic/chat/" + chatRoomId, wsMessage);
    }

    @Override
    public void sendTypingIndicator(Long chatRoomId, Long senderId, boolean isTyping) {
        WebSocketChatMessage wsMessage = WebSocketChatMessage.builder()
                .type("TYPING")
                .chatRoomId(chatRoomId)
                .senderId(senderId)
                .content(isTyping ? "true" : "false")
                .timestamp(LocalDateTime.now())
                .build();
        log("Send typing");
        messagingTemplate.convertAndSend("/topic/chat/" + chatRoomId, wsMessage);
    }

    @Override
    public void sendReadReceipt(Long chatRoomId, Long userId) {
        WebSocketChatMessage wsMessage = WebSocketChatMessage.builder()
                .type("READ_RECEIPT")
                .chatRoomId(chatRoomId)
                .senderId(userId)
                .content("read")
                .timestamp(LocalDateTime.now())
                .build();

        messagingTemplate.convertAndSend("/topic/chat/" + chatRoomId, wsMessage);
    }
} 