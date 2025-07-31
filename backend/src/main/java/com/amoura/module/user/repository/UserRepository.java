package com.amoura.module.user.repository;

import com.amoura.module.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    Optional<User> findByUsername(String username);

    Optional<User> findByPhoneNumber(String phoneNumber);

    boolean existsByEmail(String email);

    boolean existsByUsername(String username);

    boolean existsByPhoneNumber(String phoneNumber);

    @Query("SELECT u FROM User u WHERE u.status = 'ACTIVE'")
    List<User> findAllActiveUsers();
    Optional<User> findByRefreshToken(String refreshToken);
    
    // Admin Dashboard Statistics
    @Query("SELECT COUNT(u) FROM User u")
    Long countTotalUsers();
    
    @Query("SELECT COUNT(u) FROM User u WHERE DATE(u.createdAt) = :date")
    Long countUsersByDate(@Param("date") LocalDate date);
    
    @Query("SELECT COUNT(u) FROM User u WHERE u.lastLogin >= :startTime")
    Long countActiveUsersSince(@Param("startTime") LocalDateTime startTime);
    
    @Query("SELECT DATE(u.createdAt) as date, COUNT(u) as count FROM User u " +
           "WHERE u.createdAt >= :startDate " +
           "GROUP BY DATE(u.createdAt) ORDER BY DATE(u.createdAt)")
    List<Object[]> getUserGrowthData(@Param("startDate") LocalDateTime startDate);
}