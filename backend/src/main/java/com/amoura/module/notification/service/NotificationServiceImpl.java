package com.amoura.module.notification.service;

import com.amoura.common.exception.ApiException;
import com.amoura.module.notification.domain.Notification;
import com.amoura.module.notification.domain.NotificationType;
import com.amoura.module.notification.dto.CursorPaginationRequest;
import com.amoura.module.notification.dto.CursorPaginationResponse;
import com.amoura.module.notification.dto.NotificationDTO;
import com.amoura.module.notification.dto.WebSocketNotificationMessage;
import com.amoura.module.notification.repository.NotificationRepository;
import com.amoura.module.user.domain.User;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;
    private final SimpMessagingTemplate messagingTemplate;

    private static final int MAX_LIMIT = 100;
    private static final int DEFAULT_LIMIT = 20;

    @Override
    @Transactional
    public NotificationDTO createNotification(Long userId, NotificationType type, String title, String content, 
                                            Long relatedEntityId, String relatedEntityType) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        Notification notification = Notification.builder()
                .user(user)
                .type(type)
                .title(title)
                .content(content)
                .relatedEntityId(relatedEntityId)
                .relatedEntityType(relatedEntityType)
                .isRead(false)
                .build();

        Notification savedNotification = notificationRepository.save(notification);
        log.info("Created notification for user {}: {}", userId, title);
        
        return convertToDTO(savedNotification);
    }

    @Override
    @Transactional(readOnly = true)
    public CursorPaginationResponse<NotificationDTO> getUserNotificationsWithCursor(Long userId, CursorPaginationRequest request) {
        // Validate and normalize parameters
        int limit = normalizeLimit(request.getLimit());
        String direction = normalizeDirection(request.getDirection());
        
        if (!isValidDirection(direction)) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Invalid direction parameter", "INVALID_DIRECTION");
        }
        
        List<Notification> notifications;
        Long nextCursor = null;
        Long previousCursor = null;
        Boolean hasNext = false;
        Boolean hasPrevious = false;
        
        org.springframework.data.domain.Pageable pageable = PageRequest.of(0, limit + 1); // Fetch one extra to check if there are more
        
        if (request.getCursor() == null) {
            // First page - get the most recent notifications
            notifications = notificationRepository.findByUserIdOrderByIdDesc(userId, pageable);
        } else {
            if ("NEXT".equals(direction)) {
                // Next page - get notifications with ID less than cursor
                notifications = notificationRepository.findByUserIdAndIdLessThanOrderByIdDesc(userId, request.getCursor(), pageable);
            } else {
                // Previous page - get notifications with ID greater than cursor
                notifications = notificationRepository.findByUserIdAndIdGreaterThanOrderByIdAsc(userId, request.getCursor(), pageable);
            }
        }
        
        // Check if there are more items
        if (notifications.size() > limit) {
            hasNext = true;
            notifications = notifications.subList(0, limit);
        }
        
        // Set cursors and check for previous items
        if (!notifications.isEmpty()) {
            nextCursor = notifications.get(notifications.size() - 1).getId();
            previousCursor = notifications.get(0).getId();
            
            // Check if there are previous items (for next page)
            if (request.getCursor() != null) {
                hasPrevious = notificationRepository.countByUserIdAndIdGreaterThan(userId, nextCursor) > 0;
            }
        }
        
        List<NotificationDTO> notificationDTOs = notifications.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        
        return CursorPaginationResponse.<NotificationDTO>builder()
                .data(notificationDTOs)
                .nextCursor(nextCursor)
                .previousCursor(previousCursor)
                .hasNext(hasNext)
                .hasPrevious(hasPrevious)
                .count(notificationDTOs.size())
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<NotificationDTO> getUnreadNotifications(Long userId) {
        List<Notification> notifications = notificationRepository.findUnreadByUserIdOrderByCreatedAtDesc(userId);
        return notifications.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void markAsRead(Long notificationId, Long userId) {
        // Check if notification exists
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, 
                    "Notification not found with id: " + notificationId, "NOTIFICATION_NOT_FOUND"));
        
        // Check if notification belongs to the user
        if (!notification.getUser().getId().equals(userId)) {
            throw new ApiException(HttpStatus.FORBIDDEN, 
                "You can only mark your own notifications as read", "FORBIDDEN");
        }
        
        // Check if notification is already read
        if (notification.getIsRead()) {
            log.info("Notification {} is already marked as read", notificationId);
            return;
        }
        
        notificationRepository.markAsReadById(notificationId, LocalDateTime.now());
        log.info("Marked notification {} as read for user {}", notificationId, userId);
    }

    @Override
    @Transactional
    @Deprecated
    public void markAsRead(Long notificationId) {
        // Check if notification exists
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, 
                    "Notification not found with id: " + notificationId, "NOTIFICATION_NOT_FOUND"));
        
        // Check if notification is already read
        if (notification.getIsRead()) {
            log.info("Notification {} is already marked as read", notificationId);
            return;
        }
        
        notificationRepository.markAsReadById(notificationId, LocalDateTime.now());
        log.info("Marked notification {} as read", notificationId);
    }

    @Override
    @Transactional
    public void markAllAsRead(Long userId) {
        notificationRepository.markAllAsReadByUserId(userId, LocalDateTime.now());
        log.info("Marked all notifications as read for user {}", userId);
    }

    @Override
    @Transactional(readOnly = true)
    public Long getUnreadCount(Long userId) {
        return notificationRepository.countUnreadByUserId(userId);
    }

    @Override
    public void sendWebSocketNotification(Long userId, NotificationDTO notification) {
        WebSocketNotificationMessage message = WebSocketNotificationMessage.builder()
                .id(notification.getId().toString())
                .type(notification.getType())
                .title(notification.getTitle())
                .content(notification.getContent())
                .relatedEntityId(notification.getRelatedEntityId())
                .relatedEntityType(notification.getRelatedEntityType())
                .timestamp(LocalDateTime.now())
                .action("CREATE")
                .build();

        messagingTemplate.convertAndSendToUser(
                userId.toString(),
                "/queue/notification",
                message
        );
        
        log.info("Sent WebSocket notification to user {}: {}", userId, notification.getTitle());
    }

    @Override
    @Transactional
    public void sendMatchNotification(Long userId, Long matchId, String matchedUsername) {
        String title = "New Match!";
        String content = String.format("You and %s have matched! Start chatting now!", matchedUsername);
        
        NotificationDTO notification = createNotification(userId, NotificationType.MATCH, title, content, matchId, "MATCH");
        sendWebSocketNotification(userId, notification);
    }

    @Override
    @Transactional
    public void sendMessageNotification(Long userId, Long messageId, String senderName) {
        String title = "New Message";
        String content = String.format("You have a new message from %s", senderName);
        
        NotificationDTO notification = createNotification(userId, NotificationType.MESSAGE, title, content, messageId, "MESSAGE");
        sendWebSocketNotification(userId, notification);
    }

    @Override
    @Transactional
    public void sendSystemNotification(Long userId, String title, String content) {
        NotificationDTO notification = createNotification(userId, NotificationType.SYSTEM, title, content, null, null);
        sendWebSocketNotification(userId, notification);
    }

    @Override
    @Transactional
    public void sendMarketingNotification(Long userId, String title, String content) {
        NotificationDTO notification = createNotification(userId, NotificationType.MARKETING, title, content, null, null);
        sendWebSocketNotification(userId, notification);
    }

    private NotificationDTO convertToDTO(Notification notification) {
        return NotificationDTO.builder()
                .id(notification.getId())
                .userId(notification.getUser().getId())
                .type(notification.getType())
                .title(notification.getTitle())
                .content(notification.getContent())
                .relatedEntityId(notification.getRelatedEntityId())
                .relatedEntityType(notification.getRelatedEntityType())
                .isRead(notification.getIsRead())
                .readAt(notification.getReadAt())
                .createdAt(notification.getCreatedAt())
                .updatedAt(notification.getUpdatedAt())
                .build();
    }

    // Private helper methods for validation
    private int normalizeLimit(Integer limit) {
        if (limit == null || limit <= 0) {
            return DEFAULT_LIMIT;
        }
        return Math.min(limit, MAX_LIMIT);
    }
    
    private String normalizeDirection(String direction) {
        if (direction == null || direction.trim().isEmpty()) {
            return "NEXT";
        }
        return direction.toUpperCase();
    }
    
    private boolean isValidDirection(String direction) {
        String normalized = normalizeDirection(direction);
        return "NEXT".equals(normalized) || "PREVIOUS".equals(normalized);
    }
} 