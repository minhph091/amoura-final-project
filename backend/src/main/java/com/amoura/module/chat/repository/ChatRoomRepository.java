package com.amoura.module.chat.repository;

import com.amoura.module.chat.domain.ChatRoom;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {
    
    @Query("SELECT cr FROM ChatRoom cr WHERE " +
           "(cr.user1.id = :userId1 AND cr.user2.id = :userId2) OR " +
           "(cr.user1.id = :userId2 AND cr.user2.id = :userId1)")
    Optional<ChatRoom> findByUsers(@Param("userId1") Long userId1, @Param("userId2") Long userId2);
    
    @Query("SELECT cr FROM ChatRoom cr WHERE " +
           "(cr.user1.id = :userId OR cr.user2.id = :userId) AND cr.isActive = true " +
           "ORDER BY cr.updatedAt DESC")
    List<ChatRoom> findByUserIdOrderByUpdatedAtDesc(@Param("userId") Long userId, Pageable pageable);
    
    @Query("SELECT cr FROM ChatRoom cr WHERE " +
           "(cr.user1.id = :userId OR cr.user2.id = :userId) AND cr.isActive = true " +
           "AND cr.updatedAt < (SELECT MAX(m.createdAt) FROM Message m WHERE m.chatRoom = cr) " +
           "ORDER BY cr.updatedAt DESC")
    List<ChatRoom> findActiveChatRoomsByUserId(@Param("userId") Long userId, Pageable pageable);
    
    @Query("SELECT COUNT(cr) FROM ChatRoom cr WHERE " +
           "(cr.user1.id = :userId OR cr.user2.id = :userId) AND cr.isActive = true")
    Long countActiveChatRoomsByUserId(@Param("userId") Long userId);
} 