package com.amoura.module.user.api;

import com.amoura.common.exception.ApiException;
import com.amoura.module.user.dto.*;
import com.amoura.module.user.service.UserService;
import com.amoura.module.user.service.UserUpdateService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
@Tag(name = "User management", description = "User management operations")
public class UserController {

    private final UserService userService;
    private final UserUpdateService userUpdateService;

    @GetMapping
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<UserDTO> getUserInfo(@AuthenticationPrincipal UserDetails userDetails) {
        UserDTO userDTO = userService.getUserByEmail(userDetails.getUsername());
        return ResponseEntity.ok(userDTO);
    }

    @PatchMapping
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<UserDTO> updateUser(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody UpdateUserRequest request) {
        UserDTO userDTO = userService.getUserByEmail(userDetails.getUsername());
        return ResponseEntity.ok(userService.updateUser(userDTO.getId(), request));
    }

    @PostMapping("/change-password")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Void> changePassword(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody ChangePasswordRequest request) {
        UserDTO userDTO = userService.getUserByEmail(userDetails.getUsername());
        userService.changePassword(userDTO.getId(), request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/change-email/request")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<EmailChangeResponse> requestEmailChange(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody EmailChangeRequest request) {
        UserDTO userDTO = userService.getUserByEmail(userDetails.getUsername());
        EmailChangeResponse response = userUpdateService.requestEmailChange(userDTO.getId(), request.getNewEmail());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/change-email/confirm")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Void> confirmEmailChange(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody EmailChangeConfirmationRequest request) {
        UserDTO userDTO = userService.getUserByEmail(userDetails.getUsername());
        userUpdateService.confirmEmailChange(userDTO.getId(), request.getOtpCode());
        return ResponseEntity.ok().build();
    }
} 