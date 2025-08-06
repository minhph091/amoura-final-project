package com.amoura.infrastructure.security;

import com.amoura.module.user.domain.User;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.LockedException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + username));

        // Kiểm tra trạng thái tài khoản và ném exception phù hợp
        String status = user.getStatus().toLowerCase();
        switch (status) {
            case "inactive":
                throw new DisabledException("Account is inactive: " + username);
            case "suspend":
                // Kiểm tra xem suspension đã hết hạn chưa
                if (user.getSuspensionUntil() != null && 
                    LocalDateTime.now().isAfter(user.getSuspensionUntil())) {
                    // Suspension đã hết hạn, tự động kích hoạt lại tài khoản
                    user.setStatus("active");
                    user.setSuspensionUntil(null);
                    user.setSuspensionReason(null);
                    userRepository.save(user);
                    // Tiếp tục xử lý bình thường
                } else {
                    // Vẫn trong thời gian suspension
                    String suspensionMessage = "Account is suspended";
                    if (user.getSuspensionUntil() != null) {
                        suspensionMessage += " until " + user.getSuspensionUntil().toString();
                    }
                    if (user.getSuspensionReason() != null) {
                        suspensionMessage += ". Reason: " + user.getSuspensionReason();
                    }
                    throw new LockedException(suspensionMessage + ": " + username);
                }
                break;
            case "banned":
                throw new LockedException("Account is banned: " + username);
            case "active":
                // Tiếp tục xử lý bình thường
                break;
            default:
                throw new DisabledException("Account status is not valid: " + username);
        }

        return new JwtTokenProvider.CustomUserDetails(
                user.getEmail(),
                user.getPassword(),
                user.getAuthorities()
        );
    }
}