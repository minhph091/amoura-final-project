package com.amoura.module.user.api;

import com.amoura.module.user.dto.*;
import com.amoura.module.user.service.AuthService;
import com.amoura.module.user.service.PasswordResetService;
import com.amoura.module.user.service.RegistrationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import java.util.Collections;
import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "User authentication operations")
public class AuthController {

    private final AuthService authService;
    private final RegistrationService registrationService;
    private final PasswordResetService passwordResetService;

    @PostMapping("/register/initiate")
    @Operation(summary = "Initiate user registration")
    public ResponseEntity<RegistrationResponse> initiateRegistration(
            @Valid @RequestBody InitiateRegistrationRequest request) {
        return ResponseEntity.ok(registrationService.initiateRegistration(request));
    }

    @PostMapping("/register/resend-otp")
    public ResponseEntity<ResendOtpResponse> resendOtp(@Valid @RequestBody ResendOtpRequest request) {
        ResendOtpResponse response = registrationService.resendOtp(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register/verify-otp")
    @Operation(summary = "Verify OTP for registration")
    public ResponseEntity<RegistrationResponse> verifyOtp(
            @Valid @RequestBody VerifyOtpRequest request) {
        return ResponseEntity.ok(registrationService.verifyOtp(request));
    }

    @PostMapping("/register/complete")
    @Operation(summary = "Complete registration")
    public ResponseEntity<RegistrationResponse> completeRegistration(
            @Valid @RequestBody CompleteRegistrationRequest request) {
        return ResponseEntity.ok(registrationService.completeRegistration(request));
    }

    @PostMapping("/login")
    @Operation(summary = "Authenticate a user")
    public ResponseEntity<AuthResponse> login(
            @Valid @RequestBody LoginRequest loginRequest, HttpServletRequest request) {
        return ResponseEntity.ok(authService.login(loginRequest, request));
    }

    @PostMapping("/login/otp/request")
    @Operation(summary = "Request OTP for login")
    public ResponseEntity<Map<String, String>> requestLoginOtp(
            @RequestParam String email) {
        authService.requestLoginOtp(email);
        return ResponseEntity.ok(Collections.singletonMap("message",
                "If your email is registered, an OTP has been sent."));
    }

    @PostMapping("/password/reset/request")
    @Operation(summary = "Request password reset")
    public ResponseEntity<PasswordResetResponse> requestPasswordReset(
            @Valid @RequestBody RequestPasswordResetRequest request) {
        return ResponseEntity.ok(passwordResetService.requestPasswordReset(request));
    }

    @PostMapping("/password/reset/verify-otp")
    @Operation(summary = "Verify OTP for password reset")
    public ResponseEntity<PasswordResetResponse> verifyPasswordResetOtp(
            @Valid @RequestBody VerifyPasswordResetOtpRequest request) {
        return ResponseEntity.ok(passwordResetService.verifyOtp(request));
    }

    @PostMapping("/password/reset")
    @Operation(summary = "Reset password with verified OTP")
    public ResponseEntity<Map<String, String>> resetPassword(
            @Valid @RequestBody ResetPasswordRequest request) {
        passwordResetService.resetPassword(request);
        return ResponseEntity.ok(Collections.singletonMap("message",
                "Password has been reset successfully."));
    }

    @PostMapping("/password/reset/resend-otp")
    @Operation(summary = "Resend OTP for password reset")
    public ResponseEntity<PasswordResetResponse> resendPasswordResetOtp(
            @RequestParam String sessionToken) {
        return ResponseEntity.ok(passwordResetService.resendOtp(sessionToken));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Refresh authentication token")
    public ResponseEntity<AuthResponse> refreshToken(@RequestBody String refreshToken) {
        return ResponseEntity.ok(authService.refreshToken(refreshToken));
    }

    @PostMapping("/logout")
    @Operation(summary = "Logout user")
    public ResponseEntity<Void> logout(@RequestBody String refreshToken) {
        authService.logout(refreshToken);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/email-available")
    @Operation(summary = "Check if email is available")
    public ResponseEntity<Boolean> isEmailAvailable(@RequestParam String email) {
        return ResponseEntity.ok(authService.isEmailAvailable(email));
    }
}