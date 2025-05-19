package com.amoura.module.user.repository;

import com.amoura.module.user.domain.RegistrationSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface RegistrationSessionRepository extends JpaRepository<RegistrationSession, Long> {

    Optional<RegistrationSession> findBySessionTokenAndExpiresAtAfter(String sessionToken, LocalDateTime now);

    Optional<RegistrationSession> findByEmailAndStatusAndExpiresAtAfter(
            String email, String status, LocalDateTime now);

    boolean existsByEmailAndStatusNotAndExpiresAtAfter(
            String email, String status, LocalDateTime now);
}