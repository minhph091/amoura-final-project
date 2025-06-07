package com.amoura.module.user.repository;

import com.amoura.module.user.domain.EmailOtpCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface EmailOtpCodeRepository extends JpaRepository<EmailOtpCode, Long> {

    @Query("SELECT e FROM EmailOtpCode e WHERE e.userId = :userId AND e.createdAt > :cooldownTime")
    List<EmailOtpCode> findRecentOtpsByUserId(
            @Param("userId") Long userId,
            @Param("cooldownTime") LocalDateTime cooldownTime);

    @Query("SELECT e FROM EmailOtpCode e WHERE e.userId = :userId AND e.expiresAt > :now AND e.used = false")
    List<EmailOtpCode> findValidOtpsByUserId(
            @Param("userId") Long userId,
            @Param("now") LocalDateTime now);

    @Query("SELECT e FROM EmailOtpCode e WHERE e.userId = :userId AND e.code = :code AND e.used = false AND e.expiresAt > :now")
    Optional<EmailOtpCode> findByUserIdAndCodeAndUsedFalseAndExpiresAtAfter(
            @Param("userId") Long userId,
            @Param("code") String code,
            @Param("now") LocalDateTime now);
} 