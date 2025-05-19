package com.amoura.module.user.service;

import com.amoura.module.user.domain.User;
import com.amoura.module.user.dto.UserDTO;
import com.amoura.module.user.dto.UpdateUserRequest;
import com.amoura.module.user.dto.ChangePasswordRequest;

import java.util.List;
import java.util.Optional;

public interface UserService {

    UserDTO getUserById(Long id);


    UserDTO getUserByEmail(String email);


    List<UserDTO> getAllUsers();


    UserDTO updateUser(Long id, UpdateUserRequest request);


    void changePassword(Long id, ChangePasswordRequest request);


    void deactivateUser(Long id);

    void activateUser(Long id);


    void updateRefreshToken(Long userId, String refreshToken);

    void invalidateRefreshToken(Long userId);


    User findByRefreshToken(String refreshToken);
}