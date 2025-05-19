package com.amoura.module.user.service;

import com.amoura.common.exception.ApiException;
import com.amoura.infrastructure.mail.EmailService;
import com.amoura.module.user.domain.OtpCode;
import com.amoura.module.user.repository.OtpCodeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class OtpService {

    private final OtpCodeRepository otpCodeRepository;
    private final EmailService emailService;

    private final SecureRandom secureRandom = new SecureRandom();

    @Value("${app.otp.expiration}")
    private long otpExpirationMs;

    @Value("${app.otp.length}")
    private int otpLength;

    @Value("${app.otp.retry-attempts}")
    private int maxRetryAttempts;

    @Value("${app.otp.cooldown}")
    private long cooldownMs;

    @Transactional
    public void generateAndSendOtp(String email, String purpose) {
        // Check for too many recent requests
        LocalDateTime cooldownTime = LocalDateTime.now().minusNanos(cooldownMs * 1000000);
        List<OtpCode> recentOtps = otpCodeRepository.findRecentOtpsByEmailAndPurpose(email, purpose, cooldownTime);

        if (recentOtps.size() >= maxRetryAttempts) {
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS,
                    "Too many OTP requests. Please try again later.", "OTP_COOLDOWN");
        }

        // Invalidate any existing OTPs
        List<OtpCode> existingOtps = otpCodeRepository.findValidOtpsByEmailAndPurpose(
                email, purpose, LocalDateTime.now());

        existingOtps.forEach(otp -> otp.setUsed(true));
        otpCodeRepository.saveAll(existingOtps);

        // Generate and save new OTP
        String otpCode = generateOtp(otpLength);

        OtpCode newOtp = OtpCode.builder()
                .email(email)
                .code(otpCode)
                .purpose(purpose)
                .used(false)
                .attempts(0)
                .createdAt(LocalDateTime.now())
                .expiresAt(LocalDateTime.now().plusNanos(otpExpirationMs * 1000000))
                .build();

        otpCodeRepository.save(newOtp);

        // Gửi OTP qua email
        emailService.sendOtpEmail(email, otpCode, purpose);

        log.info("OTP sent to {} for purpose: {}", email, purpose);
    }

    @Transactional
    public boolean verifyOtp(String email, String otpCode, String purpose) {
        LocalDateTime now = LocalDateTime.now();

        Optional<OtpCode> otpOptional = otpCodeRepository.findByEmailAndCodeAndPurposeAndUsedFalseAndExpiresAtAfter(
                email, otpCode, purpose, now);

        if (otpOptional.isEmpty()) {
            List<OtpCode> otps = otpCodeRepository.findValidOtpsByEmailAndPurpose(email, purpose, now);

            if (!otps.isEmpty()) {
                OtpCode latestOtp = otps.get(0);
                latestOtp.setAttempts(latestOtp.getAttempts() + 1);

                if (latestOtp.getAttempts() >= maxRetryAttempts) {
                    latestOtp.setUsed(true);
                }

                otpCodeRepository.save(latestOtp);
            }

            return false;
        }

        OtpCode otp = otpOptional.get();
        otp.setUsed(true);
        otpCodeRepository.save(otp);

        return true;
    }

    private String generateOtp(int length) {
        StringBuilder otp = new StringBuilder();
        for (int i = 0; i < length; i++) {
            otp.append(secureRandom.nextInt(10));
        }
        return otp.toString();
    }
}