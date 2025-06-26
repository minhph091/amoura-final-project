package com.amoura.module.chat.api;

import com.amoura.infrastructure.security.JwtTokenProvider.CustomUserDetails;
import com.amoura.module.chat.dto.*;
import com.amoura.module.chat.service.ChatService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.beans.factory.annotation.Value;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.io.IOException;

import java.util.List;

import com.amoura.module.chat.repository.MessageRepository;
import com.amoura.module.chat.repository.UserMessageVisibilityRepository;
import com.amoura.module.chat.domain.UserMessageVisibility;
import com.amoura.module.chat.domain.Message;
import org.springframework.http.HttpStatus;
import java.time.LocalDateTime;
import java.util.Optional;
import com.amoura.common.exception.ApiException;
import java.security.Principal;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
@Tag(name = "Chat", description = "Chat operations")
public class ChatController {

    private final ChatService chatService;
    private final MessageRepository messageRepository;
    private final UserMessageVisibilityRepository userMessageVisibilityRepository;
    private static final Logger log = LoggerFactory.getLogger(ChatController.class);

    @Value("${file.storage.local.upload-dir}")
    private String uploadDir;

    @Value("${file.storage.local.base-url}")
    private String baseUrl;

    // // Chat Room endpoints
    // @PostMapping("/rooms")
    // @Operation(summary = "Create or get chat room between two users")
    // @SecurityRequirement(name = "bearerAuth")
    // public ResponseEntity<ChatRoomDTO> createOrGetChatRoom(
    //         @RequestParam Long userId2,
    //         @AuthenticationPrincipal UserDetails userDetails) {
        
    //     Long userId1 = getUserId(userDetails);
    //     ChatRoomDTO chatRoom = chatService.createOrGetChatRoom(userId1, userId2);
    //     return ResponseEntity.ok(chatRoom);
    // }

    @GetMapping("/rooms")
    @Operation(summary = "Get user's chat rooms with cursor-based pagination")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<List<ChatRoomDTO>> getUserChatRooms(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(required = false) Long cursor,
            @RequestParam(defaultValue = "20") Integer limit,
            @RequestParam(defaultValue = "NEXT") String direction) {
        
        CursorPaginationRequest request = CursorPaginationRequest.builder()
                .cursor(cursor)
                .limit(limit)
                .direction(direction)
                .build();
        
        List<ChatRoomDTO> chatRooms = chatService.getUserChatRooms(getUserId(userDetails), request);
        return ResponseEntity.ok(chatRooms);
    }

    @GetMapping("/rooms/{chatRoomId}")
    @Operation(summary = "Get chat room by ID")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ChatRoomDTO> getChatRoomById(
            @PathVariable Long chatRoomId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        ChatRoomDTO chatRoom = chatService.getChatRoomById(chatRoomId, getUserId(userDetails));
        return ResponseEntity.ok(chatRoom);
    }

    @DeleteMapping("/rooms/{chatRoomId}")
    @Operation(summary = "Deactivate chat room")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Void> deactivateChatRoom(
            @PathVariable Long chatRoomId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        chatService.deactivateChatRoom(chatRoomId, getUserId(userDetails));
        return ResponseEntity.ok().build();
    }

    // Message endpoints
    @PostMapping("/messages")
    @Operation(summary = "Send a message")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<MessageDTO> sendMessage(
            @Valid @RequestBody SendMessageRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        MessageDTO message = chatService.sendMessage(request, getUserId(userDetails));
        return ResponseEntity.ok(message);
    }

    @GetMapping("/rooms/{chatRoomId}/messages")
    @Operation(summary = "Get chat messages with cursor-based pagination")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<CursorPaginationResponse<MessageDTO>> getChatMessages(
            @PathVariable Long chatRoomId,
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(required = false) Long cursor,
            @RequestParam(defaultValue = "20") Integer limit,
            @RequestParam(defaultValue = "NEXT") String direction) {
        
        CursorPaginationRequest request = CursorPaginationRequest.builder()
                .cursor(cursor)
                .limit(limit)
                .direction(direction)
                .build();
        
        CursorPaginationResponse<MessageDTO> messages = chatService.getChatMessages(
                chatRoomId, getUserId(userDetails), request);
        return ResponseEntity.ok(messages);
    }

    @PutMapping("/rooms/{chatRoomId}/messages/read")
    @Operation(summary = "Mark messages as read")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Void> markMessagesAsRead(
            @PathVariable Long chatRoomId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        chatService.markMessagesAsRead(chatRoomId, getUserId(userDetails));
        return ResponseEntity.ok().build();
    }

    @GetMapping("/rooms/{chatRoomId}/messages/unread-count")
    @Operation(summary = "Get unread message count")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Long> getUnreadMessageCount(
            @PathVariable Long chatRoomId,
            @AuthenticationPrincipal UserDetails userDetails) {
        
        Long count = chatService.getUnreadMessageCount(chatRoomId, getUserId(userDetails));
        return ResponseEntity.ok(count);
    }

    @PostMapping("/messages/{messageId}/delete-for-me")
    @Operation(summary = "Delete message for current user only")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Void> deleteMessageForMe(@PathVariable Long messageId, @AuthenticationPrincipal UserDetails userDetails) {
        Long userId = getUserId(userDetails);
        if (userMessageVisibilityRepository.findByUserIdAndMessageId(userId, messageId).isEmpty()) {
            UserMessageVisibility vis = new UserMessageVisibility(userId, messageId, LocalDateTime.now());
            userMessageVisibilityRepository.save(vis);
        }
        return ResponseEntity.ok().build();
    }

    @PostMapping("/messages/{messageId}/recall")
    @Operation(summary = "Recall message for everyone (within 30 minutes)")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Void> recallMessage(@PathVariable Long messageId, @AuthenticationPrincipal UserDetails userDetails) {
        Long userId = getUserId(userDetails);
        try {
            chatService.recallMessage(messageId, userId);
            return ResponseEntity.ok().build();
        } catch (ApiException e) {
            return ResponseEntity.status(e.getStatus()).build();
        }
    }

    // WebSocket message handlers
    @MessageMapping("/chat.sendMessage")
    public void sendMessage(@Payload SendMessageRequest request, SimpMessageHeaderAccessor headerAccessor) {
        // Handle message sending via WebSocket
        Long senderId = getUserIdFromHeader(headerAccessor);
        MessageDTO message = chatService.sendMessage(request, senderId);
        // Message will be broadcasted via sendMessageToChatRoom in ChatService
    }

    @MessageMapping("/chat.typing")
    public void sendTypingIndicator(@Payload TypingRequest request, SimpMessageHeaderAccessor headerAccessor) {
        // Handle typing indicator via WebSocket
        Long senderId = getUserIdFromHeader(headerAccessor);
        chatService.sendTypingIndicator(request.getChatRoomId(), senderId, request.isTyping());
    }

    @MessageMapping("/chat.recallMessage")
    public void recallMessageViaWebSocket(@Payload RecallMessageRequest request, SimpMessageHeaderAccessor headerAccessor) {

        Long senderId = getUserIdFromHeader(headerAccessor);
        try {
            chatService.recallMessage(request.getMessageId(), senderId);
        } catch (ApiException e) {

        }
    }

    @PostMapping(value = "/upload-image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload image for chat message")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<String> uploadChatImage(@RequestParam("file") MultipartFile file,
                                                  @RequestParam("chatRoomId") Long chatRoomId,
                                                  @AuthenticationPrincipal UserDetails userDetails) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("File is empty");
        }
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return ResponseEntity.badRequest().body("File must be an image");
        }
        // Validate chat room access
        try {
            Long userId = getUserId(userDetails);
            ChatRoomDTO chatRoom = chatService.getChatRoomById(chatRoomId, userId);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied to this chat room");
        }
        try {
            Path roomDir = Paths.get(uploadDir, "chat", chatRoomId.toString());
            if (!Files.exists(roomDir)) {
                Files.createDirectories(roomDir);
            }
            String filename = System.currentTimeMillis() + getFileExtension(file.getOriginalFilename());
            Path filePath = roomDir.resolve(filename);
            Files.copy(file.getInputStream(), filePath);
            String relativePath = "chat/" + chatRoomId + "/" + filename;
            String imageUrl = baseUrl + "/" + relativePath;
            // Trả về URL đầy đủ cho client, nhưng client sẽ gửi relativePath khi gửi message
            return ResponseEntity.ok(imageUrl);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().body("Failed to upload image");
        }
    }

    @DeleteMapping("/delete-image")
    @Operation(summary = "Delete chat image (only uploader can delete)")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<String> deleteChatImage(@RequestParam("imageUrl") String imageUrl,
                                                  @AuthenticationPrincipal UserDetails userDetails) {
        Long userId = getUserId(userDetails);
        if (imageUrl == null || !imageUrl.contains("/chat/")) {
            return ResponseEntity.badRequest().body("Invalid imageUrl");
        }
        // Nếu client gửi URL đầy đủ, parse lấy relative path
        String relativePath = imageUrl;
        if (imageUrl.startsWith(baseUrl)) {
            relativePath = imageUrl.substring(baseUrl.length() + 1); // +1 để bỏ dấu '/'
        } else if (imageUrl.startsWith("/")) {
            relativePath = imageUrl.substring(1);
        }
        Path filePath = Paths.get(uploadDir, relativePath);
        try {
            // Tìm message chứa relativePath này
            var messageOpt = messageRepository.findByImageUrl(relativePath, userId);
            if (messageOpt.isEmpty()) {
                return ResponseEntity.status(404).body("Message with this image not found");
            }
            var message = messageOpt.get();
            if (message.getImageUploaderId() == null || !message.getImageUploaderId().equals(userId)) {
                return ResponseEntity.status(403).body("You are not allowed to delete this image");
            }
            // Xóa file vật lý
            Files.deleteIfExists(filePath);
            message.setImageUrl(null);
            message.setImageUploaderId(null);
            messageRepository.save(message);
            return ResponseEntity.ok("Image deleted");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Failed to delete image");
        }
    }

    private boolean isUserInRoom(Long userId, Long roomId) {

        return true;
    }

    private String getFileExtension(String filename) {
        if (filename == null) return ".jpg";
        int lastDotIndex = filename.lastIndexOf(".");
        return lastDotIndex == -1 ? ".jpg" : filename.substring(lastDotIndex);
    }

    private Long getUserId(UserDetails userDetails) {
        if (userDetails instanceof CustomUserDetails) {
            return ((CustomUserDetails) userDetails).getId();
        }
        throw new IllegalArgumentException("UserDetails is not an instance of CustomUserDetails");
    }

    private Long getUserIdFromHeader(SimpMessageHeaderAccessor headerAccessor) {
        // Thử lấy từ session attributes trước
        Object userId = headerAccessor.getSessionAttributes().get("userId");
        if (userId instanceof Long) {
            return (Long) userId;
        }
        
        // Nếu không có trong session attributes, thử lấy từ Principal
        Principal principal = headerAccessor.getUser();
        if (principal != null && principal.getName() != null) {
            try {
                return Long.parseLong(principal.getName());
            } catch (NumberFormatException e) {
                log.warn("Invalid user ID format in principal: {}", principal.getName());
            }
        }
        
        throw new IllegalArgumentException("User ID not found in session or principal");
    }

    public static class TypingRequest {
        private Long chatRoomId;
        private boolean typing;

        public Long getChatRoomId() {
            return chatRoomId;
        }

        public void setChatRoomId(Long chatRoomId) {
            this.chatRoomId = chatRoomId;
        }

        public boolean isTyping() {
            return typing;
        }

        public void setTyping(boolean typing) {
            this.typing = typing;
        }
    }

    public static class RecallMessageRequest {
        private Long messageId;

        public Long getMessageId() {
            return messageId;
        }

        public void setMessageId(Long messageId) {
            this.messageId = messageId;
        }
    }
} 