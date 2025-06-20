package com.amoura.module.matching.service;

import com.amoura.module.matching.dto.SwipeRequest;
import com.amoura.module.matching.dto.SwipeResponse;
import com.amoura.module.matching.dto.UserRecommendationDTO;

import java.util.List;

public interface MatchingService {
    
    /**
     * Lấy danh sách người dùng được đề xuất
     */
    List<UserRecommendationDTO> getRecommendedUsers(String userEmail);
    
    /**
     * Xử lý swipe (like/pass) của người dùng
     */
    SwipeResponse swipeUser(String userEmail, SwipeRequest request);
} 