package com.amoura.module.profile.api;

import com.amoura.module.profile.dto.ProfileDTO;
import com.amoura.module.profile.dto.ProfileOptionsDTO;
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

    @PatchMapping("/me")
    @Operation(summary = "Update current user's profile")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<ProfileDTO> updateProfile(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody UpdateProfileRequest request) {
        ProfileDTO updatedProfile = profileService.updateProfile(userDetails.getUsername(), request);
        return ResponseEntity.ok(updatedProfile);
    }
} 