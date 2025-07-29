package com.amoura.module.matching.repository;

import com.amoura.module.matching.domain.Match;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MatchRepository extends JpaRepository<Match, Long> {
    
    @Query("SELECT m FROM Match m WHERE (m.user1.id = :userId OR m.user2.id = :userId) AND m.status = 'ACTIVE'")
    List<Match> findActiveMatchesByUserId(@Param("userId") Long userId);
    
    @Query("SELECT m FROM Match m WHERE (m.user1.id = :user1Id AND m.user2.id = :user2Id) OR (m.user1.id = :user2Id AND m.user2.id = :user1Id)")
    Optional<Match> findByUserIds(@Param("user1Id") Long user1Id, @Param("user2Id") Long user2Id);
    
    @Query("SELECT m FROM Match m WHERE (m.user1.id = :user1Id AND m.user2.id = :user2Id) OR (m.user1.id = :user2Id AND m.user2.id = :user1Id) AND m.status = 'ACTIVE'")
    Optional<Match> findActiveMatchByUserIds(@Param("user1Id") Long user1Id, @Param("user2Id") Long user2Id);
    
    @Query("SELECT m FROM Match m WHERE m.user1.id = :userId OR m.user2.id = :userId")
    List<Match> findAllByUserId(@Param("userId") Long userId);

    @Query("SELECT m FROM Match m WHERE " +
           "(m.user1.id = :userId1 AND m.user2.id = :userId2) OR " +
           "(m.user1.id = :userId2 AND m.user2.id = :userId1)")
    Optional<Match> findByUsers(@Param("userId1") Long userId1, @Param("userId2") Long userId2);
} 