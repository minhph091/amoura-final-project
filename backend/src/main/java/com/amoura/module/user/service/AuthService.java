package com.amoura.module.user.service;

import com.amoura.module.user.dto.AuthResponse;
import com.amoura.module.user.dto.LoginRequest;

import jakarta.servlet.http.HttpServletRequest;

public interface AuthService {

    AuthResponse login(LoginRequest loginRequest, HttpServletRequest request);

    AuthResponse refreshToken(String refreshToken);

    void logout(String refreshToken);

    boolean isEmailAvailable(String email);

    void requestLoginOtp(String email);
}