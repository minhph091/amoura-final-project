package com.amoura.module.matching.repository;

import com.amoura.module.matching.domain.Swipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

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
} 