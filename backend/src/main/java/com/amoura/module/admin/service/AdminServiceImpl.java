package com.amoura.module.admin.service;

import com.amoura.module.admin.dto.AdminDashboardDTO;
import com.amoura.module.chat.repository.MessageRepository;
import com.amoura.module.matching.repository.MatchRepository;
import com.amoura.module.matching.repository.SwipeRepository;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdminServiceImpl implements AdminService {

    private final UserRepository userRepository;
    private final MatchRepository matchRepository;
    private final MessageRepository messageRepository;
    private final SwipeRepository swipeRepository;

    @Override
    @Transactional(readOnly = true)
    public AdminDashboardDTO getDashboardOverview() {
        log.info("Fetching admin dashboard overview");

        // Get current statistics
        LocalDate today = LocalDate.now();
        LocalDateTime startOfDay = today.atStartOfDay();
        LocalDateTime last30Days = LocalDateTime.now().minusDays(30);

        // Basic counts
        Long totalUsers = userRepository.countTotalUsers();
        Long totalMatches = matchRepository.countTotalMatches();
        Long totalMessages = messageRepository.countTotalMessages();
        Long todayUsers = userRepository.countUsersByDate(today);
        Long todayMatches = matchRepository.countMatchesByDate(today);
        Long todayMessages = messageRepository.countMessagesByDate(today);
        Long activeUsersToday = userRepository.countActiveUsersSince(startOfDay);

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
            List<Object[]> userGrowthData = userRepository.getUserGrowthData(startDate);
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
            List<Object[]> swipeData = swipeRepository.getSwipeStatistics(startDate);
            List<Object[]> matchData = matchRepository.getMatchesData(startDate);
            
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
        
        try {
            LocalDateTime now = LocalDateTime.now();
            
            // Add sample recent activities (you can expand this based on your needs)
            activities.add(AdminDashboardDTO.RecentActivityData.builder()
                    .activityType("SYSTEM_INFO")
                    .description("Dashboard data refreshed")
                    .timestamp(now.toString())
                    .userId(null)
                    .username("System")
                    .build());
                    
            
        } catch (Exception e) {
            log.error("Error building recent activities: {}", e.getMessage());
        }
        
        return activities;
    }
} 