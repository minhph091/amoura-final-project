package com.amoura.module.admin.service;

import com.amoura.module.admin.dto.AdminDashboardDTO;
import com.amoura.module.admin.dto.CursorPaginationRequest;
import com.amoura.module.admin.dto.CursorPaginationResponse;
import com.amoura.module.admin.dto.UserManagementDTO;
import com.amoura.module.admin.dto.UserStatusUpdateRequest;
import com.amoura.module.admin.repository.AdminRepository;
import com.amoura.module.user.domain.User;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
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
    private final UserRepository userRepository;

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
    
    @Override
    @Transactional(readOnly = true)
    public CursorPaginationResponse<UserManagementDTO> getUsersWithCursor(CursorPaginationRequest request) {
        log.info("Fetching users with cursor pagination - cursor: {}, limit: {}, direction: {}", 
                request.getCursor(), request.getLimit(), request.getDirection());
        
        // Validate and normalize parameters
        int limit = normalizeLimit(request.getLimit());
        String direction = normalizeDirection(request.getDirection());
        
        if (!isValidDirection(direction)) {
            throw new RuntimeException("Invalid direction parameter: " + direction);
        }
        
        List<Object[]> users;
        Long nextCursor = null;
        Long previousCursor = null;
        Boolean hasNext = false;
        Boolean hasPrevious = false;
        
        PageRequest pageable = PageRequest.of(0, limit + 1); // Fetch one extra to check if there are more
        
        if (request.getCursor() == null) {
            // First page - get the most recent users
            users = adminRepository.findAllUsersForManagement(pageable);
        } else {
            if ("NEXT".equals(direction)) {
                // Next page - get users with ID less than cursor
                users = adminRepository.findUsersForManagementWithCursorNext(request.getCursor(), pageable);
            } else {
                // Previous page - get users with ID greater than cursor
                users = adminRepository.findUsersForManagementWithCursorPrevious(request.getCursor(), pageable);
            }
        }
        
        // Check if there are more items
        if (users.size() > limit) {
            hasNext = "NEXT".equals(direction) || request.getCursor() == null;
            hasPrevious = "PREVIOUS".equals(direction);
            users = users.subList(0, limit);
        }
        
        // Set cursors
        if (!users.isEmpty()) {
            if ("PREVIOUS".equals(direction)) {
                // For previous direction, reverse the order to maintain correct sorting
                java.util.Collections.reverse(users);
            }
            nextCursor = ((Number) users.get(users.size() - 1)[0]).longValue();
            previousCursor = ((Number) users.get(0)[0]).longValue();
        }
        
        // Convert to DTOs
        List<UserManagementDTO> userDTOs = users.stream()
                .map(this::convertToUserManagementDTO)
                .toList();
        
        return CursorPaginationResponse.<UserManagementDTO>builder()
                .data(userDTOs)
                .nextCursor(nextCursor)
                .previousCursor(previousCursor)
                .hasNext(hasNext)
                .hasPrevious(hasPrevious)
                .count(userDTOs.size())
                .build();
    }
    
    @Override
    @Transactional(readOnly = true)
    public CursorPaginationResponse<UserManagementDTO> searchUsers(String searchTerm, CursorPaginationRequest request) {
        log.info("Searching users with term: {} and cursor pagination", searchTerm);
        
        if (searchTerm == null || searchTerm.trim().isEmpty()) {
            return getUsersWithCursor(request);
        }
        
        int limit = normalizeLimit(request.getLimit());
        PageRequest pageable = PageRequest.of(0, limit + 1);
        
        List<Object[]> users = adminRepository.searchUsersForManagement(searchTerm.trim(), pageable);
        
        Boolean hasNext = users.size() > limit;
        if (hasNext) {
            users = users.subList(0, limit);
        }
        
        Long nextCursor = null;
        Long previousCursor = null;
        
        if (!users.isEmpty()) {
            nextCursor = ((Number) users.get(users.size() - 1)[0]).longValue();
            previousCursor = ((Number) users.get(0)[0]).longValue();
        }
        
        List<UserManagementDTO> userDTOs = users.stream()
                .map(this::convertToUserManagementDTO)
                .toList();
        
        return CursorPaginationResponse.<UserManagementDTO>builder()
                .data(userDTOs)
                .nextCursor(nextCursor)
                .previousCursor(previousCursor)
                .hasNext(hasNext)
                .hasPrevious(false) // Search doesn't support previous navigation
                .count(userDTOs.size())
                .build();
    }
    
    @Override
    @Transactional(readOnly = true)
    public UserManagementDTO getUserById(Long userId) {
        log.info("Fetching user details for ID: {}", userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));
        
        // Fetch additional data using native query
        List<Object[]> userData = adminRepository.findUsersForManagementWithCursorNext(userId + 1, PageRequest.of(0, 1));
        if (userData.isEmpty()) {
            userData = adminRepository.findAllUsersForManagement(PageRequest.of(0, Integer.MAX_VALUE))
                    .stream()
                    .filter(row -> ((Number) row[0]).longValue() == userId.longValue())
                    .toList();
        }
        
        if (!userData.isEmpty()) {
            return convertToUserManagementDTO(userData.get(0));
        }
        
        // Fallback to basic conversion
        return UserManagementDTO.builder()
                .id(user.getId())
                .username(user.getActualUsername())
                .email(user.getEmail())
                .phoneNumber(user.getPhoneNumber())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .fullName(user.getFullName())
                .roleName(user.getRole() != null ? user.getRole().getName() : "USER")
                .status(user.getStatus())
                .lastLogin(user.getLastLogin())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .hasProfile(user.getProfile() != null)
                .photoCount(0)
                .totalMatches(0L)
                .totalMessages(0L)
                .build();
    }
    
    @Override
    @Transactional
    public UserManagementDTO updateUserStatus(Long userId, UserStatusUpdateRequest request) {
        log.info("Updating user status for ID: {} to status: {}", userId, request.getStatus());
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));
        
        String oldStatus = user.getStatus();
        user.setStatus(request.getStatus());
        userRepository.save(user);
        
        log.info("User {} status updated from {} to {} for reason: {}", 
                userId, oldStatus, request.getStatus(), request.getReason());
        
        return getUserById(userId);
    }
    
    @Override
    @Transactional
    public void suspendUser(Long userId) {
        log.info("Suspending user with ID: {}", userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));
        
        user.setStatus("SUSPEND");
        userRepository.save(user);
        
        log.info("User {} has been suspended (status set to SUSPEND)", userId);
    }
    
    @Override
    @Transactional
    public void restoreUser(Long userId) {
        log.info("Restoring user with ID: {}", userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));
        
        String oldStatus = user.getStatus();
        user.setStatus("ACTIVE");
        userRepository.save(user);
        
        log.info("User {} has been restored from {} to ACTIVE", userId, oldStatus);
    }
    
    // Helper methods
    private int normalizeLimit(Integer limit) {
        if (limit == null || limit < 1) {
            return 20; // Default limit
        }
        return Math.min(limit, 100); // Max limit of 100
    }
    
    private String normalizeDirection(String direction) {
        if (direction == null) {
            return "NEXT";
        }
        return direction.toUpperCase();
    }
    
    private boolean isValidDirection(String direction) {
        return "NEXT".equals(direction) || "PREVIOUS".equals(direction);
    }
    
    private UserManagementDTO convertToUserManagementDTO(Object[] row) {
        return UserManagementDTO.builder()
                .id(((Number) row[0]).longValue())
                .username((String) row[1])
                .email((String) row[2])
                .phoneNumber((String) row[3])
                .firstName((String) row[4])
                .lastName((String) row[5])
                .fullName(((String) row[4]) + " " + ((String) row[5]))
                .roleName((String) row[6])
                .status((String) row[7])
                .lastLogin((LocalDateTime) row[8])
                .createdAt((LocalDateTime) row[9])
                .updatedAt((LocalDateTime) row[10])
                .hasProfile((Boolean) row[11])
                .photoCount(((Number) row[12]).intValue())
                .totalMatches(((Number) row[13]).longValue())
                .totalMessages(((Number) row[14]).longValue())
                .build();
    }
} 