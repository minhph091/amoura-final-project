package com.amoura.module.admin.service;

import com.amoura.module.admin.dto.AdminDashboardDTO;
import com.amoura.module.admin.repository.AdminRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdminServiceImpl implements AdminService {

    private final AdminRepository adminRepository;

    @Override
    @Transactional(readOnly = true)
    public AdminDashboardDTO getDashboardOverview() {
        log.info("Fetching admin dashboard overview");

        // Get current statistics
        LocalDate today = LocalDate.now();
        LocalDateTime startOfDay = today.atStartOfDay();
        LocalDateTime last30Days = LocalDateTime.now().minusDays(30);

        // Basic counts
        Long totalUsers = adminRepository.countTotalUsers();
        Long totalMatches = adminRepository.countTotalMatches();
        Long totalMessages = adminRepository.countTotalMessages();
        Long todayUsers = adminRepository.countUsersByDate(today);
        Long todayMatches = adminRepository.countMatchesByDate(today);
        Long todayMessages = adminRepository.countMessagesByDate(today);
        Long activeUsersToday = adminRepository.countActiveUsersSince(startOfDay);

        // User growth chart data (last 30 days)
        List<AdminDashboardDTO.UserGrowthData> userGrowthChart = buildUserGrowthChart(last30Days);

        // Matching success rate chart data (last 30 days)
        List<AdminDashboardDTO.MatchingSuccessData> matchingSuccessChart = buildMatchingSuccessChart(last30Days);

        // Recent activities (simplified for now)
        List<AdminDashboardDTO.RecentActivityData> recentActivities = buildRecentActivities();

        return AdminDashboardDTO.builder()
                .totalUsers(totalUsers)
                .totalMatches(totalMatches)
                .totalMessages(totalMessages)
                .todayUsers(todayUsers)
                .todayMatches(todayMatches)
                .todayMessages(todayMessages)
                .activeUsersToday(activeUsersToday)
                .userGrowthChart(userGrowthChart)
                .matchingSuccessChart(matchingSuccessChart)
                .recentActivities(recentActivities)
                .build();
    }

    private List<AdminDashboardDTO.UserGrowthData> buildUserGrowthChart(LocalDateTime startDate) {
        List<AdminDashboardDTO.UserGrowthData> chartData = new ArrayList<>();
        
        try {
            List<Object[]> userGrowthData = adminRepository.getUserGrowthData(startDate);
            Long cumulativeTotal = 0L;
            
            for (Object[] row : userGrowthData) {
                LocalDate date = (LocalDate) row[0];
                Long newUsers = ((Number) row[1]).longValue();
                cumulativeTotal += newUsers;
                
                chartData.add(AdminDashboardDTO.UserGrowthData.builder()
                        .date(date)
                        .newUsers(newUsers)
                        .totalUsers(cumulativeTotal)
                        .build());
            }
        } catch (Exception e) {
            log.error("Error building user growth chart: {}", e.getMessage());
        }
        
        return chartData;
    }

    private List<AdminDashboardDTO.MatchingSuccessData> buildMatchingSuccessChart(LocalDateTime startDate) {
        List<AdminDashboardDTO.MatchingSuccessData> chartData = new ArrayList<>();
        
        try {
            // Get swipe statistics
            List<Object[]> swipeData = adminRepository.getSwipeStatistics(startDate);
            List<Object[]> matchData = adminRepository.getMatchesData(startDate);
            
            // Create a map for easier lookup of match data by date
            var matchMap = new java.util.HashMap<LocalDate, Long>();
            for (Object[] row : matchData) {
                LocalDate date = (LocalDate) row[0];
                Long matches = ((Number) row[1]).longValue();
                matchMap.put(date, matches);
            }
            
            // Build chart data combining swipe and match information
            for (Object[] row : swipeData) {
                LocalDate date = (LocalDate) row[0];
                Long totalSwipes = ((Number) row[1]).longValue();
                Long likes = ((Number) row[2]).longValue();
                Long matches = matchMap.getOrDefault(date, 0L);
                
                // Calculate success rate as matches per likes (not per total swipes)
                Double successRate = likes > 0 ? (matches.doubleValue() / likes.doubleValue()) * 100.0 : 0.0;
                
                chartData.add(AdminDashboardDTO.MatchingSuccessData.builder()
                        .date(date)
                        .totalSwipes(totalSwipes)
                        .totalMatches(matches)
                        .successRate(Math.round(successRate * 100.0) / 100.0) // Round to 2 decimal places
                        .build());
            }
        } catch (Exception e) {
            log.error("Error building matching success chart: {}", e.getMessage());
            // Return empty list if there's an error
        }
        
        return chartData;
    }

    private List<AdminDashboardDTO.RecentActivityData> buildRecentActivities() {
        List<AdminDashboardDTO.RecentActivityData> activities = new ArrayList<>();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        
        try {
            LocalDateTime last24Hours = LocalDateTime.now().minusDays(1);
            
            // Get recent user registrations
            List<Object[]> recentUsers = adminRepository.getRecentUserRegistrations(last24Hours, 5);
            for (Object[] row : recentUsers) {
                Long userId = ((Number) row[0]).longValue();
                String username = (String) row[1];
                String firstName = (String) row[2];
                LocalDateTime createdAt = (LocalDateTime) row[4];
                
                activities.add(AdminDashboardDTO.RecentActivityData.builder()
                        .activityType("USER_REGISTRATION")
                        .description(String.format("New user %s (%s) registered", firstName, username))
                        .timestamp(createdAt.format(formatter))
                        .userId(userId)
                        .username(username)
                        .build());
            }
            
            // Get recent matches
            List<Object[]> recentMatches = adminRepository.getRecentMatches(last24Hours, 5);
            for (Object[] row : recentMatches) {
                Long matchId = ((Number) row[0]).longValue();
                String user1Name = (String) row[1];
                String user2Name = (String) row[2];
                LocalDateTime matchedAt = (LocalDateTime) row[3];
                
                activities.add(AdminDashboardDTO.RecentActivityData.builder()
                        .activityType("MATCH_CREATED")
                        .description(String.format("Match created between %s and %s", user1Name, user2Name))
                        .timestamp(matchedAt.format(formatter))
                        .userId(matchId)
                        .username("System")
                        .build());
            }
            
            // Add system info
            activities.add(AdminDashboardDTO.RecentActivityData.builder()
                    .activityType("SYSTEM_INFO")
                    .description("Dashboard data refreshed")
                    .timestamp(LocalDateTime.now().format(formatter))
                    .userId(null)
                    .username("System")
                    .build());
            
        } catch (Exception e) {
            log.error("Error building recent activities: {}", e.getMessage());
            
            // Fallback activity
            activities.add(AdminDashboardDTO.RecentActivityData.builder()
                    .activityType("SYSTEM_INFO")
                    .description("Dashboard data refreshed")
                    .timestamp(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")))
                    .userId(null)
                    .username("System")
                    .build());
        }
        
        // Sort by timestamp descending
        activities.sort((a, b) -> b.getTimestamp().compareTo(a.getTimestamp()));
        
        return activities;
    }
} 