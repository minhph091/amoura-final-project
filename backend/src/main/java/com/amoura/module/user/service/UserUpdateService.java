package com.amoura.module.user.service;

import com.amoura.common.exception.ApiException;
import com.amoura.infrastructure.mail.EmailService;
import com.amoura.module.user.domain.EmailOtpCode;
import com.amoura.module.user.domain.User;
import com.amoura.module.user.dto.EmailChangeResponse;
import com.amoura.module.user.repository.EmailOtpCodeRepository;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserUpdateService {

    private final UserRepository userRepository;
    private final EmailOtpCodeRepository emailOtpCodeRepository;
    private final EmailService emailService;
    private final SecureRandom secureRandom = new SecureRandom();

    @Value("${app.otp.expiration}")
    private long otpExpirationMs;

    @Value("${app.otp.length}")
    private int otpLength;

    private static final long COOLDOWN_SECONDS = 60;

    @Transactional
    public EmailChangeResponse requestEmailChange(Long userId, String newEmail) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        // Check if email is already in use
        if (userRepository.existsByEmail(newEmail)) {
            throw new ApiException(HttpStatus.CONFLICT, "Email already in use", "EMAIL_EXISTS");
        }

        // Check cooldown period
        LocalDateTime cooldownTime = LocalDateTime.now().minusSeconds(COOLDOWN_SECONDS);
        List<EmailOtpCode> recentOtps = emailOtpCodeRepository.findRecentOtpsByUserId(userId, cooldownTime);
        
        if (!recentOtps.isEmpty()) {
            EmailOtpCode latestOtp = recentOtps.stream()
                    .max((o1, o2) -> o1.getCreatedAt().compareTo(o2.getCreatedAt()))
                    .orElseThrow();

            LocalDateTime nextRequestTime = latestOtp.getCreatedAt().plusSeconds(COOLDOWN_SECONDS);
            long remainingSeconds = ChronoUnit.SECONDS.between(LocalDateTime.now(), nextRequestTime);

            if (remainingSeconds > 0) {
                return EmailChangeResponse.builder()
                        .message("Please wait before requesting another OTP")
                        .nextRequestTime(nextRequestTime)
                        .remainingSeconds(remainingSeconds)
                        .build();
            }
        }

        // Invalidate all existing OTPs for this user
        List<EmailOtpCode> existingOtps = emailOtpCodeRepository.findValidOtpsByUserId(userId, LocalDateTime.now());
        existingOtps.forEach(otp -> otp.setUsed(true));
        emailOtpCodeRepository.saveAll(existingOtps);

        // Generate and save new OTP
        String otpCode = generateOtp(otpLength);
        EmailOtpCode newOtp = EmailOtpCode.builder()
                .userId(userId)
                .email(newEmail)
                .code(otpCode)
                .used(false)
                .attempts(0)
                .createdAt(LocalDateTime.now())
                .expiresAt(LocalDateTime.now().plusNanos(otpExpirationMs * 1000000))
                .build();

        emailOtpCodeRepository.save(newOtp);

        // Send OTP email
        emailService.sendEmailChangeOtpEmail(newEmail, otpCode, 5);
        log.info("Email change OTP sent to {} for user {}", newEmail, userId);

        return EmailChangeResponse.builder()
                .message("OTP has been sent to your new email address")
                .nextRequestTime(LocalDateTime.now().plusSeconds(COOLDOWN_SECONDS))
                .remainingSeconds(COOLDOWN_SECONDS)
                .build();
    }

    @Transactional
    public void confirmEmailChange(Long userId, String otpCode) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        // Get all valid OTPs for this user
        List<EmailOtpCode> validOtps = emailOtpCodeRepository.findValidOtpsByUserId(userId, LocalDateTime.now());
        
        // Find the latest OTP that matches the provided code
        Optional<EmailOtpCode> matchingOtp = validOtps.stream()
                .filter(otp -> otp.getCode().equals(otpCode))
                .max((o1, o2) -> o1.getCreatedAt().compareTo(o2.getCreatedAt()));

        if (matchingOtp.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Invalid or expired OTP", "INVALID_OTP");
        }

        EmailOtpCode otp = matchingOtp.get();

        // Update user's email
        user.setEmail(otp.getEmail());
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);

        // Mark all OTPs as used
        validOtps.forEach(o -> o.setUsed(true));
        emailOtpCodeRepository.saveAll(validOtps);

        log.info("Email changed for user {} to {}", userId, otp.getEmail());
    }

    private String generateOtp(int length) {
        StringBuilder otp = new StringBuilder();
        for (int i = 0; i < length; i++) {
            otp.append(secureRandom.nextInt(10));
        }
        return otp.toString();
    }
} 