package com.amoura.module.matching.repository;

import com.amoura.module.matching.domain.Swipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface SwipeRepository extends JpaRepository<Swipe, Long> {
    
    @Query("SELECT s FROM Swipe s WHERE s.initiator.id = :initiatorId AND s.targetUser.id = :targetUserId")
    Optional<Swipe> findByInitiatorAndTargetUser(@Param("initiatorId") Long initiatorId, 
                                                @Param("targetUserId") Long targetUserId);
    
    @Query("SELECT s FROM Swipe s WHERE s.initiator.id = :userId OR s.targetUser.id = :userId")
    List<Swipe> findByUserId(@Param("userId") Long userId);
    
    @Query("SELECT s FROM Swipe s WHERE s.initiator.id = :userId")
    List<Swipe> findByInitiatorId(@Param("userId") Long userId);
    
    @Query("SELECT s FROM Swipe s WHERE s.targetUser.id = :userId")
    List<Swipe> findByTargetUserId(@Param("userId") Long userId);
    
    @Query("SELECT s FROM Swipe s WHERE s.initiator.id = :initiatorId AND s.targetUser.id = :targetUserId AND s.isLike = true")
    Optional<Swipe> findLikeByInitiatorAndTargetUser(@Param("initiatorId") Long initiatorId, 
                                                    @Param("targetUserId") Long targetUserId);
    
    @Query("SELECT s FROM Swipe s WHERE s.targetUser.id = :targetUserId AND s.isLike = true ORDER BY s.createdAt ASC")
    List<Swipe> findLikesReceivedByUser(@Param("targetUserId") Long targetUserId);
    
    @Query("SELECT s FROM Swipe s WHERE s.targetUser.id = :targetUserId AND s.isLike = true " +
           "AND NOT EXISTS (SELECT s2 FROM Swipe s2 WHERE s2.initiator.id = :targetUserId AND s2.targetUser.id = s.initiator.id) " +
           "ORDER BY s.createdAt DESC")
    List<Swipe> findPendingLikesReceivedByUser(@Param("targetUserId") Long targetUserId);
    
    // Admin Dashboard Statistics  
    @Query("SELECT DATE(s.createdAt) as date, COUNT(s) as totalSwipes, " +
           "SUM(CASE WHEN s.isLike = true THEN 1 ELSE 0 END) as likes FROM Swipe s " +
           "WHERE s.createdAt >= :startDate " +
           "GROUP BY DATE(s.createdAt) ORDER BY DATE(s.createdAt)")
    List<Object[]> getSwipeStatistics(@Param("startDate") LocalDateTime startDate);
} 