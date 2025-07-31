package com.amoura.module.admin.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminDashboardDTO {
    
    // System Overview Statistics
    private Long totalUsers;
    private Long totalMatches; 
    private Long totalMessages;
    private Long todayUsers;
    private Long todayMatches;
    private Long todayMessages;
    private Long activeUsersToday;
    
    // User Growth Chart Data
    private List<UserGrowthData> userGrowthChart;
    
    // Matching Success Rate Chart Data
    private List<MatchingSuccessData> matchingSuccessChart;
    
    // Recent Activity
    private List<RecentActivityData> recentActivities;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserGrowthData {
        private LocalDate date;
        private Long newUsers;
        private Long totalUsers;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MatchingSuccessData {
        private LocalDate date;
        private Long totalSwipes;
        private Long totalMatches;
        private Double successRate; // percentage
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class RecentActivityData {
        private String activityType; // USER_REGISTRATION, MATCH_CREATED, MESSAGE_SENT
        private String description;
        private String timestamp;
        private Long userId;
        private String username;
    }
} 