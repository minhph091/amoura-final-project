package com.amoura.infrastructure.security;

import com.amoura.module.user.domain.User;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + username));

        if (!"active".equalsIgnoreCase(user.getStatus())) {
            throw new UsernameNotFoundException("Account is not active: " + username);
        }

        return new JwtTokenProvider.CustomUserDetails(
                user.getEmail(),
                user.getPassword(),
                user.getAuthorities()
        );
    }
}