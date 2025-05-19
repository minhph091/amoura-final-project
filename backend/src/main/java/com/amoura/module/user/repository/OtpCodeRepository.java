package com.amoura.module.user.repository;

import com.amoura.module.user.domain.OtpCode;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface OtpCodeRepository extends JpaRepository<OtpCode, Long> {

    Optional<OtpCode> findByEmailAndCodeAndPurposeAndUsedFalseAndExpiresAtAfter(
            String email, String code, String purpose, LocalDateTime now);

    @Query("SELECT o FROM OtpCode o WHERE o.email = :email AND o.purpose = :purpose " +
            "AND o.used = false AND o.expiresAt > :now ORDER BY o.createdAt DESC")
    List<OtpCode> findValidOtpsByEmailAndPurpose(String email, String purpose, LocalDateTime now);

    @Query("SELECT o FROM OtpCode o WHERE o.email = :email AND o.purpose = :purpose " +
            "AND o.createdAt > :since ORDER BY o.createdAt DESC")
    List<OtpCode> findRecentOtpsByEmailAndPurpose(String email, String purpose, LocalDateTime since);
}