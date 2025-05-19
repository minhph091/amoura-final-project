package com.amoura.module.user.service;

import com.amoura.common.exception.ApiException;
import com.amoura.infrastructure.security.JwtTokenProvider;
import com.amoura.module.profile.domain.Profile;
import com.amoura.module.profile.repository.ProfileRepository;
import com.amoura.module.user.domain.RegistrationSession;
import com.amoura.module.user.domain.Role;
import com.amoura.module.user.domain.User;
import com.amoura.module.user.dto.*;
import com.amoura.module.user.repository.RegistrationSessionRepository;
import com.amoura.module.user.repository.RoleRepository;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.Period;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class RegistrationService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ProfileRepository profileRepository;
    private final RegistrationSessionRepository registrationSessionRepository;
    private final OtpService otpService;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    @Value("${app.registration.session-timeout}")
    private long sessionTimeoutMs;

    @Transactional
    public RegistrationResponse initiateRegistration(InitiateRegistrationRequest request) {
        // Kiểm tra email đã được sử dụng chưa
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ApiException(HttpStatus.CONFLICT, "Email already in use", "EMAIL_ALREADY_EXISTS");
        }

        // Kiểm tra số điện thoại đã được sử dụng chưa (nếu có)
        if (request.getPhoneNumber() != null && !request.getPhoneNumber().isEmpty()
                && userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
            throw new ApiException(HttpStatus.CONFLICT, "Phone number already in use", "PHONE_ALREADY_EXISTS");
        }

        // Kiểm tra xem có phiên đăng ký đang hoạt động không
        if (registrationSessionRepository.existsByEmailAndStatusNotAndExpiresAtAfter(
                request.getEmail(), "COMPLETED", LocalDateTime.now())) {
            throw new ApiException(HttpStatus.CONFLICT,
                    "Registration already in progress", "REGISTRATION_IN_PROGRESS");
        }

        // Tạo phiên đăng ký
        String sessionToken = UUID.randomUUID().toString();
        LocalDateTime expiresAt = LocalDateTime.now().plusNanos(sessionTimeoutMs * 1000000);

        RegistrationSession session = RegistrationSession.builder()
                .sessionToken(sessionToken)
                .email(request.getEmail())
                .phoneNumber(request.getPhoneNumber())
                .password(passwordEncoder.encode(request.getPassword()))
                .status("INITIATED")
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .expiresAt(expiresAt)
                .build();

        registrationSessionRepository.save(session);

        // Tạo và gửi OTP
        otpService.generateAndSendOtp(request.getEmail(), "REGISTRATION");

        // Trả về phản hồi
        return RegistrationResponse.builder()
                .sessionToken(sessionToken)
                .status("INITIATED")
                .message("Registration initiated. Please verify your email with the OTP sent.")
                .expiresIn(ChronoUnit.SECONDS.between(LocalDateTime.now(), expiresAt))
                .build();
    }

    @Transactional
    public RegistrationResponse verifyOtp(VerifyOtpRequest request) {
        // Lấy phiên đăng ký
        RegistrationSession session = getValidSession(request.getSessionToken());

        // Xác thực OTP
        boolean isValid = otpService.verifyOtp(session.getEmail(), request.getOtpCode(), "REGISTRATION");

        if (!isValid) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Invalid or expired OTP", "INVALID_OTP");
        }

        // Cập nhật trạng thái phiên
        session.setStatus("VERIFIED");
        session.setUpdatedAt(LocalDateTime.now());
        registrationSessionRepository.save(session);

        // Trả về phản hồi
        return RegistrationResponse.builder()
                .sessionToken(session.getSessionToken())
                .status("VERIFIED")
                .message("Email verified. Please complete your profile.")
                .expiresIn(ChronoUnit.SECONDS.between(LocalDateTime.now(), session.getExpiresAt()))
                .build();
    }

    @Transactional
    public RegistrationResponse completeRegistration(CompleteRegistrationRequest request) {
        // Lấy phiên đăng ký
        RegistrationSession session = getValidSession(request.getSessionToken());

        // Kiểm tra xem phiên có được xác thực chưa
        if (!session.getStatus().equals("VERIFIED")) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Email not verified", "EMAIL_NOT_VERIFIED");
        }

        // Lấy vai trò người dùng mặc định
        Role userRole = roleRepository.findByName("USER")
                .orElseThrow(() -> new ApiException(HttpStatus.INTERNAL_SERVER_ERROR,
                        "Default role not found", "ROLE_NOT_FOUND"));

        // Tạo người dùng
        User user = User.builder()
                .username(generateUsername(request.getFirstName(), request.getLastName()))
                .email(session.getEmail())
                .password(session.getPassword())
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .phoneNumber(session.getPhoneNumber())
                .role(userRole)
                .status("ACTIVE".toLowerCase())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        User savedUser = userRepository.save(user);

        // Tạo hồ sơ cơ bản
        Profile profile = Profile.builder()
                .userId(savedUser.getId())
                .user(savedUser)
                .dateOfBirth(request.getDateOfBirth())
                .sex(request.getSex())
                .build();

        profileRepository.save(profile);

        // Cập nhật trạng thái phiên
        session.setFirstName(request.getFirstName());
        session.setLastName(request.getLastName());
        session.setStatus("COMPLETED");
        session.setUpdatedAt(LocalDateTime.now());
        registrationSessionRepository.save(session);

        // Tạo token JWT
        String accessToken = jwtTokenProvider.createToken(
                savedUser.getEmail(),
                savedUser.getAuthorities(),
                savedUser.getId()
        );
        String refreshToken = jwtTokenProvider.createRefreshToken(savedUser.getEmail());

        // Ánh xạ người dùng sang UserDTO
        UserDTO userDTO = UserDTO.builder()
                .id(savedUser.getId())
                .username(savedUser.getUsername())
                .email(savedUser.getEmail())
                .phoneNumber(savedUser.getPhoneNumber())
                .firstName(savedUser.getFirstName())
                .lastName(savedUser.getLastName())
                .fullName(savedUser.getFullName())
                .roleName(savedUser.getRole().getName())
                .status(savedUser.getStatus())
                .createdAt(savedUser.getCreatedAt())
                .updatedAt(savedUser.getUpdatedAt())
                .build();

        // Trả về phản hồi với người dùng và token
        AuthResponse authResponse = AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .user(userDTO)
                .build();

        return RegistrationResponse.builder()
                .sessionToken(null)
                .status("COMPLETED")
                .message("Registration completed successfully.")
                .expiresIn(null)
                .user(userDTO)
                .authResponse(authResponse)
                .build();
    }

    private RegistrationSession getValidSession(String sessionToken) {
        return registrationSessionRepository.findBySessionTokenAndExpiresAtAfter(
                        sessionToken, LocalDateTime.now())
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST,
                        "Invalid or expired session", "INVALID_SESSION"));
    }

    private String generateUsername(String firstName, String lastName) {
        String baseUsername = (firstName.toLowerCase() + lastName.toLowerCase())
                .replaceAll("[^a-z0-9]", "");

        // Cắt ngắn nếu quá dài
        if (baseUsername.length() > 15) {
            baseUsername = baseUsername.substring(0, 15);
        }

        // Kiểm tra xem username đã tồn tại chưa và thêm số nếu cần
        String username = baseUsername;
        int counter = 1;

        while (userRepository.existsByUsername(username)) {
            username = baseUsername + counter;
            counter++;
        }

        return username;
    }

    // Phương thức tính tuổi từ ngày sinh
    private int calculateAge(LocalDateTime dateOfBirth) {
        return Period.between(dateOfBirth.toLocalDate(), LocalDateTime.now().toLocalDate()).getYears();
    }
}