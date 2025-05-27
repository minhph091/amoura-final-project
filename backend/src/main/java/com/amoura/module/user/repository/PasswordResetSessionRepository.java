package com.amoura.module.user.repository;

import com.amoura.module.user.domain.PasswordResetSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface PasswordResetSessionRepository extends JpaRepository<PasswordResetSession, Long> {

    Optional<PasswordResetSession> findBySessionTokenAndExpiresAtAfter(String sessionToken, LocalDateTime now);

    Optional<PasswordResetSession> findByEmailAndStatusAndExpiresAtAfter(
            String email, String status, LocalDateTime now);

    boolean existsByEmailAndStatusNotAndExpiresAtAfter(
            String email, String status, LocalDateTime now);
} 