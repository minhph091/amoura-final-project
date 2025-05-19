package com.amoura.module.user.service;

import com.amoura.common.exception.ApiException;
import com.amoura.module.user.domain.User;
import com.amoura.module.user.dto.RequestPasswordResetRequest;
import com.amoura.module.user.dto.ResetPasswordRequest;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class PasswordResetService {

    private final UserRepository userRepository;
    private final OtpService otpService;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public void requestPasswordReset(RequestPasswordResetRequest request) {
        // Check if email exists
        if (!userRepository.existsByEmail(request.getEmail())) {
            log.info("Password reset requested for non-existent email: {}", request.getEmail());
            return;
        }

        // Generate and send OTP
        otpService.generateAndSendOtp(request.getEmail(), "PASSWORD_RESET");

        log.info("Password reset OTP sent to: {}", request.getEmail());
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        // Verify OTP
        boolean isValid = otpService.verifyOtp(request.getEmail(), request.getOtpCode(), "PASSWORD_RESET");

        if (!isValid) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Invalid or expired OTP", "INVALID_OTP");
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND,
                        "User not found", "USER_NOT_FOUND"));

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        user.setUpdatedAt(java.time.LocalDateTime.now());
        userRepository.save(user);

        log.info("Password reset completed for: {}", request.getEmail());
    }
}