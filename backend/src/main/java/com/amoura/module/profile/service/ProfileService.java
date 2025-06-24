package com.amoura.module.profile.service;

import com.amoura.module.profile.dto.ProfileDTO;
import com.amoura.module.profile.dto.ProfileResponseDTO;
import com.amoura.module.profile.dto.ProfileOptionsDTO;
import com.amoura.module.user.dto.UpdateProfileRequest;

public interface ProfileService {
    ProfileResponseDTO getProfile(String email);
    ProfileResponseDTO updateProfile(String email, UpdateProfileRequest request);
    ProfileOptionsDTO getAllProfileOptions();
    ProfileResponseDTO getProfileById(Long userId);
} 