package com.amoura.module.profile.api;

import com.amoura.module.profile.dto.ProfileDTO;
import com.amoura.module.profile.dto.ProfileOptionsDTO;
import com.amoura.module.profile.dto.ProfileResponseDTO;
import com.amoura.module.profile.service.ProfileService;
import com.amoura.module.user.dto.UpdateProfileRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("profiles")
@RequiredArgsConstructor
@Tag(name = "Profile", description = "Profile management operations")
public class ProfileController {

    private final ProfileService profileService;

    @GetMapping("/options")
    @Operation(summary = "Get all profile configuration options")
    public ResponseEntity<ProfileOptionsDTO> getProfileOptions() {
        ProfileOptionsDTO options = profileService.getAllProfileOptions();
        return ResponseEntity.ok(options);
    }

    @GetMapping("/me")
    @Operation(summary = "Get current user's profile")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ProfileResponseDTO> getProfile(
            @AuthenticationPrincipal UserDetails userDetails) {
        ProfileResponseDTO profile = profileService.getProfile(userDetails.getUsername());
        return ResponseEntity.ok(profile);
    }

    @PatchMapping("/me")
    @Operation(summary = "Update current user's profile")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ProfileResponseDTO> updateProfile(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody UpdateProfileRequest request) {
        ProfileResponseDTO updatedProfile = profileService.updateProfile(userDetails.getUsername(), request);
        return ResponseEntity.ok(updatedProfile);
    }

    @GetMapping("/{userId}")
    @Operation(summary = "Get profile of a specific user by ID")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ProfileResponseDTO> getProfileById(@PathVariable Long userId) {
        ProfileResponseDTO profile = profileService.getProfileById(userId);
        return ResponseEntity.ok(profile);
    }
} 