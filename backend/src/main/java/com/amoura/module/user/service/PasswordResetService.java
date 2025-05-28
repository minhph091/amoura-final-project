package com.amoura.module.user.service;

import com.amoura.common.exception.ApiException;
import com.amoura.module.user.domain.PasswordResetSession;
import com.amoura.module.user.domain.User;
import com.amoura.module.user.dto.*;
import com.amoura.module.user.repository.PasswordResetSessionRepository;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class PasswordResetService {

    private final UserRepository userRepository;
    private final PasswordResetSessionRepository passwordResetSessionRepository;
    private final OtpService otpService;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.password-reset.session-timeout}")
    private long sessionTimeoutMs;

    @Value("${app.otp.resend-cooldown-seconds:60}")
    private long otpResendCooldownSeconds;

    @Transactional
    public PasswordResetResponse requestPasswordReset(RequestPasswordResetRequest request) {
        // Check if email exists
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        // Check if there's an active reset session
        if (passwordResetSessionRepository.existsByEmailAndStatusNotAndExpiresAtAfter(
                request.getEmail(), "COMPLETED", LocalDateTime.now())) {
            throw new ApiException(HttpStatus.CONFLICT,
                    "Password reset already in progress", "RESET_IN_PROGRESS");
        }

        // Create reset session
        String sessionToken = UUID.randomUUID().toString();
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiresAt = now.plusNanos(sessionTimeoutMs * 1000000);

        PasswordResetSession session = PasswordResetSession.builder()
                .sessionToken(sessionToken)
                .user(user)
                .email(request.getEmail())
                .status("INITIATED")
                .createdAt(now)
                .updatedAt(now)
                .expiresAt(expiresAt)
                .lastOtpSentAt(now)
                .build();
        passwordResetSessionRepository.save(session);

        // Generate and send OTP
        otpService.generateAndSendOtp(request.getEmail(), "PASSWORD_RESET");

        return PasswordResetResponse.builder()
                .sessionToken(sessionToken)
                .status("INITIATED")
                .message("Password reset initiated. Please verify your email with the OTP sent.")
                .expiresIn(ChronoUnit.SECONDS.between(now, expiresAt))
                .build();
    }

    @Transactional
    public PasswordResetResponse verifyOtp(VerifyPasswordResetOtpRequest request) {
        PasswordResetSession session = getValidSession(request.getSessionToken());

        if (!"INITIATED".equals(session.getStatus())) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Invalid session state for OTP verification", "INVALID_SESSION_STATE");
        }

        // Verify OTP
        boolean isValid = otpService.verifyOtp(session.getEmail(), request.getOtpCode(), "PASSWORD_RESET");
        if (!isValid) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Invalid or expired OTP", "INVALID_OTP");
        }

        // Update session status
        session.setStatus("VERIFIED");
        session.setUpdatedAt(LocalDateTime.now());
        passwordResetSessionRepository.save(session);

        return PasswordResetResponse.builder()
                .sessionToken(session.getSessionToken())
                .status("VERIFIED")
                .message("OTP verified. Please set your new password.")
                .expiresIn(ChronoUnit.SECONDS.between(LocalDateTime.now(), session.getExpiresAt()))
                .build();
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        PasswordResetSession session = getValidSession(request.getSessionToken());

        if (!"VERIFIED".equals(session.getStatus())) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "OTP must be verified before resetting password", "OTP_NOT_VERIFIED");
        }

        User user = session.getUser();
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);

        // Mark session as completed
        session.setStatus("COMPLETED");
        session.setUpdatedAt(LocalDateTime.now());
        passwordResetSessionRepository.save(session);

        log.info("Password reset completed for user: {}", user.getEmail());
    }

    @Transactional
    public PasswordResetResponse resendOtp(String sessionToken) {
        PasswordResetSession session = getValidSession(sessionToken);

        if (!"INITIATED".equals(session.getStatus())) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Cannot resend OTP for the current session state",
                    "INVALID_SESSION_STATE_FOR_RESEND");
        }

        LocalDateTime now = LocalDateTime.now();
        if (session.getLastOtpSentAt() != null) {
            LocalDateTime nextResendAllowedAt = session.getLastOtpSentAt().plusSeconds(otpResendCooldownSeconds);
            if (now.isBefore(nextResendAllowedAt)) {
                long secondsRemaining = ChronoUnit.SECONDS.between(now, nextResendAllowedAt);
                throw new ApiException(HttpStatus.TOO_MANY_REQUESTS,
                        "Please wait " + secondsRemaining + " seconds before requesting a new OTP.",
                        "OTP_RESEND_RATE_LIMITED");
            }
        }

        otpService.generateAndSendOtp(session.getEmail(), "PASSWORD_RESET");

        session.setLastOtpSentAt(now);
        session.setUpdatedAt(now);
        passwordResetSessionRepository.save(session);

        return PasswordResetResponse.builder()
                .sessionToken(session.getSessionToken())
                .status("INITIATED")
                .message("A new OTP has been sent to your email.")
                .expiresIn(ChronoUnit.SECONDS.between(now, session.getExpiresAt()))
                .build();
    }

    private PasswordResetSession getValidSession(String sessionToken) {
        return passwordResetSessionRepository.findBySessionTokenAndExpiresAtAfter(
                        sessionToken, LocalDateTime.now())
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST,
                        "Invalid or expired session", "INVALID_SESSION"));
    }
}