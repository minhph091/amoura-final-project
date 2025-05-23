package com.amoura.module.profile.service;

import com.amoura.module.profile.dto.ProfileDTO;
import com.amoura.module.user.dto.UpdateProfileRequest;

public interface ProfileService {
    ProfileDTO updateProfile(String email, UpdateProfileRequest request);
} 