package com.amoura.module.notification.repository;

import com.amoura.module.notification.domain.Notification;
import com.amoura.module.notification.domain.NotificationType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    
    @Query("SELECT n FROM Notification n WHERE n.user.id = :userId ORDER BY n.createdAt DESC")
    Page<Notification> findByUserIdOrderByCreatedAtDesc(@Param("userId") Long userId, Pageable pageable);
    
    // Cursor-based pagination methods
    @Query("SELECT n FROM Notification n WHERE n.user.id = :userId AND n.id < :cursor ORDER BY n.id DESC")
    List<Notification> findByUserIdAndIdLessThanOrderByIdDesc(@Param("userId") Long userId, 
                                                             @Param("cursor") Long cursor, 
                                                             org.springframework.data.domain.Pageable pageable);
    
    @Query("SELECT n FROM Notification n WHERE n.user.id = :userId AND n.id > :cursor ORDER BY n.id ASC")
    List<Notification> findByUserIdAndIdGreaterThanOrderByIdAsc(@Param("userId") Long userId, 
                                                               @Param("cursor") Long cursor, 
                                                               org.springframework.data.domain.Pageable pageable);
    
    @Query("SELECT n FROM Notification n WHERE n.user.id = :userId ORDER BY n.id DESC")
    List<Notification> findByUserIdOrderByIdDesc(@Param("userId") Long userId, 
                                                org.springframework.data.domain.Pageable pageable);
    
    @Query("SELECT COUNT(n) FROM Notification n WHERE n.user.id = :userId AND n.id < :cursor")
    Long countByUserIdAndIdLessThan(@Param("userId") Long userId, @Param("cursor") Long cursor);
    
    @Query("SELECT COUNT(n) FROM Notification n WHERE n.user.id = :userId AND n.id > :cursor")
    Long countByUserIdAndIdGreaterThan(@Param("userId") Long userId, @Param("cursor") Long cursor);
    
    @Query("SELECT n FROM Notification n WHERE n.user.id = :userId AND n.type = :type ORDER BY n.createdAt DESC")
    List<Notification> findByUserIdAndTypeOrderByCreatedAtDesc(@Param("userId") Long userId, @Param("type") NotificationType type);
    
    @Query("SELECT COUNT(n) FROM Notification n WHERE n.user.id = :userId AND n.isRead = false")
    Long countUnreadByUserId(@Param("userId") Long userId);
    
    @Query("SELECT n FROM Notification n WHERE n.user.id = :userId AND n.isRead = false ORDER BY n.createdAt DESC")
    List<Notification> findUnreadByUserIdOrderByCreatedAtDesc(@Param("userId") Long userId);
    
    @Query("SELECT n FROM Notification n WHERE n.user.id = :userId AND n.relatedEntityId = :entityId AND n.relatedEntityType = :entityType")
    Optional<Notification> findByUserIdAndRelatedEntity(@Param("userId") Long userId, 
                                                       @Param("entityId") Long entityId, 
                                                       @Param("entityType") String entityType);
    
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true, n.readAt = :readAt WHERE n.user.id = :userId AND n.isRead = false")
    void markAllAsReadByUserId(@Param("userId") Long userId, @Param("readAt") LocalDateTime readAt);
    
    @Modifying
    @Query("UPDATE Notification n SET n.isRead = true, n.readAt = :readAt WHERE n.id = :notificationId")
    void markAsReadById(@Param("notificationId") Long notificationId, @Param("readAt") LocalDateTime readAt);
    
    @Query("SELECT n FROM Notification n WHERE n.user.id = :userId AND n.createdAt >= :since ORDER BY n.createdAt DESC")
    List<Notification> findRecentByUserId(@Param("userId") Long userId, @Param("since") LocalDateTime since);
} 