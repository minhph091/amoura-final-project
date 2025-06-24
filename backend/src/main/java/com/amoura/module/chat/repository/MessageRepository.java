package com.amoura.module.chat.repository;

import com.amoura.module.chat.domain.Message;
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
public interface MessageRepository extends JpaRepository<Message, Long> {
    
    @Query("SELECT m FROM Message m WHERE m.chatRoom.id = :chatRoomId " +
           "ORDER BY m.createdAt DESC")
    List<Message> findByChatRoomIdOrderByCreatedAtDesc(@Param("chatRoomId") Long chatRoomId, Pageable pageable);
    
    @Query("SELECT m FROM Message m WHERE m.chatRoom.id = :chatRoomId " +
           "AND m.id < :cursor " +
           "ORDER BY m.createdAt DESC")
    List<Message> findByChatRoomIdAndCursorOrderByCreatedAtDesc(
            @Param("chatRoomId") Long chatRoomId, 
            @Param("cursor") Long cursor, 
            Pageable pageable);
    
    @Query("SELECT m FROM Message m WHERE m.chatRoom.id = :chatRoomId " +
           "AND m.id > :cursor " +
           "ORDER BY m.createdAt ASC")
    List<Message> findByChatRoomIdAndCursorOrderByCreatedAtAsc(
            @Param("chatRoomId") Long chatRoomId, 
            @Param("cursor") Long cursor, 
            Pageable pageable);
    
    @Query("SELECT m FROM Message m WHERE m.chatRoom.id = :chatRoomId " +
           "ORDER BY m.createdAt DESC")
    List<Message> findLatestMessagesByChatRoomId(@Param("chatRoomId") Long chatRoomId, Pageable pageable);
    
    @Query("SELECT COUNT(m) FROM Message m WHERE m.chatRoom.id = :chatRoomId " +
           "AND m.sender.id != :userId AND m.isRead = false")
    Long countUnreadMessagesByChatRoomIdAndUserId(@Param("chatRoomId") Long chatRoomId, @Param("userId") Long userId);
    
    @Query("SELECT m FROM Message m WHERE m.chatRoom.id = :chatRoomId " +
           "AND m.sender.id != :userId AND m.isRead = false")
    List<Message> findUnreadMessagesByChatRoomIdAndUserId(@Param("chatRoomId") Long chatRoomId, @Param("userId") Long userId);
    
    @Modifying
    @Query("UPDATE Message m SET m.isRead = true, m.readAt = :readAt " +
           "WHERE m.chatRoom.id = :chatRoomId AND m.sender.id != :userId AND m.isRead = false")
    void markMessagesAsRead(@Param("chatRoomId") Long chatRoomId, @Param("userId") Long userId, @Param("readAt") LocalDateTime readAt);
    
    @Query("SELECT m FROM Message m WHERE m.id = :messageId AND m.chatRoom.id = :chatRoomId")
    Optional<Message> findByIdAndChatRoomId(@Param("messageId") Long messageId, @Param("chatRoomId") Long chatRoomId);
    
    @Query("SELECT MAX(m.createdAt) FROM Message m WHERE m.chatRoom.id = :chatRoomId")
    Optional<LocalDateTime> findLastMessageTimeByChatRoomId(@Param("chatRoomId") Long chatRoomId);

    Optional<Message> findByImageUrl(String imageUrl);

    @Query("""
    SELECT m FROM Message m
    WHERE m.chatRoom.id = :chatRoomId
    AND m.id NOT IN (
        SELECT v.messageId FROM UserMessageVisibility v WHERE v.userId = :userId
    )
    ORDER BY m.createdAt DESC
    """)
    List<Message> findVisibleMessagesForUser(@Param("chatRoomId") Long chatRoomId, @Param("userId") Long userId, Pageable pageable);
} 