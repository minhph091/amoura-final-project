package com.amoura.module.admin.repository;

import com.amoura.module.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AdminRepository extends JpaRepository<User, Long> {
    
    // User Statistics
    @Query(value = "SELECT COUNT(*) FROM users", nativeQuery = true)
    Long countTotalUsers();
    
    @Query(value = "SELECT COUNT(*) FROM users WHERE DATE(created_at) = :date", nativeQuery = true)
    Long countUsersByDate(@Param("date") LocalDate date);
    
    @Query(value = "SELECT COUNT(*) FROM users WHERE last_login >= :startTime", nativeQuery = true)
    Long countActiveUsersSince(@Param("startTime") LocalDateTime startTime);
    
    @Query(value = "SELECT DATE(created_at) as date, COUNT(*) as count FROM users " +
                   "WHERE created_at >= :startDate " +
                   "GROUP BY DATE(created_at) ORDER BY DATE(created_at)", nativeQuery = true)
    List<Object[]> getUserGrowthData(@Param("startDate") LocalDateTime startDate);
    
    // Match Statistics
    @Query(value = "SELECT COUNT(*) FROM matches", nativeQuery = true)
    Long countTotalMatches();
    
    @Query(value = "SELECT COUNT(*) FROM matches WHERE DATE(matched_at) = :date", nativeQuery = true)
    Long countMatchesByDate(@Param("date") LocalDate date);
    
    @Query(value = "SELECT DATE(matched_at) as date, COUNT(*) as matches FROM matches " +
                   "WHERE matched_at >= :startDate " +
                   "GROUP BY DATE(matched_at) ORDER BY DATE(matched_at)", nativeQuery = true)
    List<Object[]> getMatchesData(@Param("startDate") LocalDateTime startDate);
    
    // Message Statistics
    @Query(value = "SELECT COUNT(*) FROM messages", nativeQuery = true)
    Long countTotalMessages();
    
    @Query(value = "SELECT COUNT(*) FROM messages WHERE DATE(created_at) = :date", nativeQuery = true)
    Long countMessagesByDate(@Param("date") LocalDate date);
    
    // Swipe Statistics
    @Query(value = "SELECT DATE(created_at) as date, COUNT(*) as totalSwipes, " +
                   "SUM(CASE WHEN is_like = true THEN 1 ELSE 0 END) as likes FROM swipes " +
                   "WHERE created_at >= :startDate " +
                   "GROUP BY DATE(created_at) ORDER BY DATE(created_at)", nativeQuery = true)
    List<Object[]> getSwipeStatistics(@Param("startDate") LocalDateTime startDate);
    
    // Recent User Activities
    @Query(value = "SELECT u.id, u.username, u.first_name, u.last_name, u.created_at " +
                   "FROM users u " +
                   "WHERE u.created_at >= :since " +
                   "ORDER BY u.created_at DESC " +
                   "LIMIT :limit", nativeQuery = true)
    List<Object[]> getRecentUserRegistrations(@Param("since") LocalDateTime since, @Param("limit") int limit);
    
    // Recent Match Activities
    @Query(value = "SELECT m.id, u1.username as user1_name, u2.username as user2_name, m.matched_at " +
                   "FROM matches m " +
                   "JOIN users u1 ON m.user1_id = u1.id " +
                   "JOIN users u2 ON m.user2_id = u2.id " +
                   "WHERE m.matched_at >= :since " +
                   "ORDER BY m.matched_at DESC " +
                   "LIMIT :limit", nativeQuery = true)
    List<Object[]> getRecentMatches(@Param("since") LocalDateTime since, @Param("limit") int limit);
    
    // System Health Check
    @Query(value = "SELECT " +
                   "(SELECT COUNT(*) FROM users WHERE status = 'ACTIVE') as active_users, " +
                   "(SELECT COUNT(*) FROM users WHERE status = 'SUSPENDED') as suspended_users, " +
                   "(SELECT COUNT(*) FROM users WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') as new_users_week, " +
                   "(SELECT COUNT(*) FROM matches WHERE matched_at >= CURRENT_DATE - INTERVAL '7 days') as new_matches_week",
                   nativeQuery = true)
    List<Object[]> getSystemHealthMetrics();
} 