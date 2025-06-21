package com.amoura.module.notification.service;

import com.amoura.module.notification.domain.NotificationType;
import com.amoura.module.notification.dto.CursorPaginationRequest;
import com.amoura.module.notification.dto.CursorPaginationResponse;
import com.amoura.module.notification.dto.NotificationDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface NotificationService {
    
 
    // Tạo notification mới
    NotificationDTO createNotification(Long userId, NotificationType type, String title, String content, 
                                     Long relatedEntityId, String relatedEntityType);
    

    CursorPaginationResponse<NotificationDTO> getUserNotificationsWithCursor(Long userId, CursorPaginationRequest request);
    
    List<NotificationDTO> getUnreadNotifications(Long userId);
    
    //  Đánh dấu notification đã đọc (với validation user)

    void markAsRead(Long notificationId, Long userId);
    

    @Deprecated
    void markAsRead(Long notificationId);
    
    void markAllAsRead(Long userId);
    
    Long getUnreadCount(Long userId);
    
    void sendWebSocketNotification(Long userId, NotificationDTO notification);
    

    void sendMatchNotification(Long userId, Long matchId, String matchedUsername);
    

    void sendMessageNotification(Long userId, Long messageId, String senderName);
    
 
    void sendSystemNotification(Long userId, String title, String content);
    

    void sendMarketingNotification(Long userId, String title, String content);
} 