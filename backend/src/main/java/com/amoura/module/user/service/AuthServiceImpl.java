package com.amoura.module.user.service;

import com.amoura.common.exception.ApiException;
import com.amoura.infrastructure.security.JwtTokenProvider;
import com.amoura.module.user.domain.LoginHistory;
import com.amoura.module.user.domain.User;
import com.amoura.module.user.dto.AuthResponse;
import com.amoura.module.user.dto.LoginRequest;
import com.amoura.module.user.dto.UserDTO;
import com.amoura.module.user.repository.LoginHistoryRepository;
import com.amoura.module.user.repository.UserRepository;
import com.amoura.infrastructure.security.SecurityConfig;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final LoginHistoryRepository loginHistoryRepository;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;
    private final OtpService otpService;
    private final UserService userService;

    @Override
    public AuthResponse login(LoginRequest loginRequest, HttpServletRequest request) {
        // Đầu tiên xác thực người dùng (không sử dụng @Transactional)
        User user = authenticateUser(loginRequest);

        return finalizeLogin(user, request);
    }

    private User authenticateUser(LoginRequest loginRequest) {
        if (loginRequest == null) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Login request is required", "LOGIN_REQUEST_REQUIRED");
        }

        switch (loginRequest.getLoginType()) {
            case "EMAIL_PASSWORD":
                return authenticateWithEmailPassword(loginRequest.getEmail(), loginRequest.getPassword());
            case "PHONE_PASSWORD":
                return authenticateWithPhonePassword(loginRequest.getPhoneNumber(), loginRequest.getPassword());
            case "EMAIL_OTP":
                return authenticateWithEmailOtp(loginRequest.getEmail(), loginRequest.getOtpCode());
            default:
                throw new ApiException(HttpStatus.BAD_REQUEST,
                        "Unsupported login type: " + loginRequest.getLoginType(), "INVALID_LOGIN_TYPE");
        }
    }


    @Transactional
    protected AuthResponse finalizeLogin(User user, HttpServletRequest request) {
        try {
            // Cập nhật thời gian đăng nhập cuối
            user.setLastLogin(LocalDateTime.now());
            userRepository.save(user);

            // Lưu lịch sử đăng nhập
            saveLoginHistory(user, request, true);

            // Tạo token JWT
            String accessToken = jwtTokenProvider.createToken(
                    user.getEmail(),
                    user.getAuthorities(),
                    user.getId()
            );
            String refreshToken = jwtTokenProvider.createRefreshToken(user.getEmail());

            // Cập nhật refresh token
            userService.updateRefreshToken(user.getId(), refreshToken);

            return AuthResponse.builder()
                    .accessToken(accessToken)
                    .refreshToken(refreshToken)
                    .user(mapToUserDTO(user))
                    .build();
        } catch (Exception e) {
            log.error("Error finalizing login for user {}: {}", user.getEmail(), e.getMessage(), e);
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Could not complete login process", "LOGIN_ERROR");
        }
    }

    private User authenticateWithEmailPassword(String email, String password) {
        if (email == null || email.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Email is required", "EMAIL_REQUIRED");
        }

        if (password == null || password.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Password is required", "PASSWORD_REQUIRED");
        }

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        try {
            // Tạo token xác thực
            UsernamePasswordAuthenticationToken authenticationToken =
                    new UsernamePasswordAuthenticationToken(email, password);


            Authentication authentication = authenticationManager.authenticate(authenticationToken);

            // Lưu vào SecurityContext nếu xác thực thành công
            SecurityContextHolder.getContext().setAuthentication(authentication);

            return user;
        } catch (BadCredentialsException e) {
            log.error("Invalid credentials for email: {}", email);
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid credentials", "INVALID_CREDENTIALS");
        } catch (Exception e) {
            log.error("Authentication error for email {}: {}", email, e.getMessage(), e);
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Authentication failed", "AUTHENTICATION_FAILED");
        }
    }

    private User authenticateWithPhonePassword(String phoneNumber, String password) {
        if (phoneNumber == null || phoneNumber.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Phone number is required", "PHONE_REQUIRED");
        }

        if (password == null || password.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Password is required", "PASSWORD_REQUIRED");
        }

        User user = userRepository.findByPhoneNumber(phoneNumber)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(user.getEmail(), password)
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);
            return user;
        } catch (BadCredentialsException e) {
            log.error("Invalid credentials for phone: {}", phoneNumber);
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid credentials", "INVALID_CREDENTIALS");
        } catch (Exception e) {
            log.error("Authentication error for phone {}: {}", phoneNumber, e.getMessage(), e);
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Authentication failed", "AUTHENTICATION_FAILED");
        }
    }

    private User authenticateWithEmailOtp(String email, String otpCode) {
        if (email == null || email.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Email is required", "EMAIL_REQUIRED");
        }

        if (otpCode == null || otpCode.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "OTP code is required", "OTP_REQUIRED");
        }

        // Tìm user theo email
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        // Xác thực OTP
        boolean isValid = otpService.verifyOtp(email, otpCode, "LOGIN");
        if (!isValid) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Invalid or expired OTP", "INVALID_OTP");
        }

        return user;
    }

    @Override
    @Transactional
    public AuthResponse refreshToken(String refreshToken) {
        if (refreshToken == null || refreshToken.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Refresh token is required", "REFRESH_TOKEN_REQUIRED");
        }

        // Xác thực refresh token
        String username = jwtTokenProvider.getUsernameFromRefreshToken(refreshToken);
        if (username == null) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid refresh token", "INVALID_REFRESH_TOKEN");
        }

        // Lấy thông tin người dùng
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        // Kiểm tra xem refresh token có khớp với token được lưu không
        if (user.getRefreshToken() == null || !user.getRefreshToken().equals(refreshToken)) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid refresh token", "INVALID_REFRESH_TOKEN");
        }

        // Kiểm tra trạng thái tài khoản
        if (!user.getStatus().equalsIgnoreCase("ACTIVE")) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Account is not active", "ACCOUNT_NOT_ACTIVE");
        }

        // Tạo token mới
        String newAccessToken = jwtTokenProvider.createToken(
                user.getEmail(),
                user.getAuthorities(),
                user.getId()
        );
        String newRefreshToken = jwtTokenProvider.createRefreshToken(user.getEmail());

        // Cập nhật refresh token mới vào cơ sở dữ liệu
        userService.updateRefreshToken(user.getId(), newRefreshToken);

        return AuthResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .user(mapToUserDTO(user))
                .build();
    }

    @Override
    @Transactional
    public void logout(String refreshToken) {
        if (refreshToken == null || refreshToken.isEmpty()) {
            return;
        }

        try {
            // Lấy username từ refresh token
            String username = jwtTokenProvider.getUsernameFromRefreshToken(refreshToken);
            if (username != null) {
                // Tìm user
                Optional<User> userOpt = userRepository.findByEmail(username);
                if (userOpt.isPresent()) {
                    // Xóa refresh token
                    userService.invalidateRefreshToken(userOpt.get().getId());
                }
            }
        } catch (Exception e) {
            log.error("Error during logout: {}", e.getMessage());
        }
    }

    @Override
    public boolean isEmailAvailable(String email) {
        return !userRepository.existsByEmail(email);
    }

    @Override
    public void requestLoginOtp(String email) {
        if (!userRepository.existsByEmail(email)) {
            log.info("Login OTP requested for non-existent email: {}", email);
            return;
        }

        otpService.generateAndSendOtp(email, "LOGIN");
        log.info("Login OTP sent to: {}", email);
    }

    private void saveLoginHistory(User user, HttpServletRequest request, boolean successful) {
        try {
            LoginHistory loginHistory = LoginHistory.builder()
                    .user(user)
                    .loginTime(LocalDateTime.now())
                    .ipAddress(getClientIp(request))
                    .userAgent(request.getHeader("User-Agent"))
                    .successful(successful)
                    .build();

            loginHistoryRepository.save(loginHistory);
        } catch (Exception e) {
            log.error("Could not save login history", e);
        }
    }

    private UserDTO mapToUserDTO(User user) {
        return UserDTO.builder()
                .id(user.getId())
                .username(user.getActualUsername())
                .email(user.getEmail())
                .phoneNumber(user.getPhoneNumber())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .fullName(user.getFullName())
                .roleName(user.getRole().getName())
                .status(user.getStatus())
                .lastLogin(user.getLastLogin())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }

    private String getClientIp(HttpServletRequest request) {
        String ipAddress = request.getHeader("X-Forwarded-For");
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getHeader("Proxy-Client-IP");
        }
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getRemoteAddr();
        }

        if (ipAddress != null && ipAddress.contains(",")) {
            ipAddress = ipAddress.split(",")[0].trim();
        }

        return ipAddress;
    }
}