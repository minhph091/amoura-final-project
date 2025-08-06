package com.amoura.module.admin.api;

import com.amoura.module.admin.dto.AdminDashboardDTO;
import com.amoura.module.admin.dto.CursorPaginationRequest;
import com.amoura.module.admin.dto.CursorPaginationResponse;
import com.amoura.module.admin.dto.StatusUpdateResponse;
import com.amoura.module.admin.dto.UserManagementDTO;
import com.amoura.module.admin.dto.UserStatusUpdateRequest;
import com.amoura.module.admin.service.AdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Admin", description = "Admin management operations")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/dashboard")
    @Operation(
        summary = "Get admin dashboard overview", 
        description = "Returns system statistics including total users, matches, messages, user growth chart data, and matching success rates"
    )
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<AdminDashboardDTO> getDashboard() {
        log.info("Admin dashboard requested");
        
        AdminDashboardDTO dashboard = adminService.getDashboardOverview();
        
        log.info("Dashboard data fetched successfully - Total Users: {}, Total Matches: {}, Total Messages: {}", 
                dashboard.getTotalUsers(), dashboard.getTotalMatches(), dashboard.getTotalMessages());
        
        return ResponseEntity.ok(dashboard);
    }
    
    @GetMapping("/users")
    @Operation(
        summary = "Get users with cursor pagination",
        description = "Returns a paginated list of users for admin management with cursor-based pagination"
    )
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Users retrieved successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid pagination parameters"),
        @ApiResponse(responseCode = "403", description = "Access denied - admin role required")
    })
    public ResponseEntity<CursorPaginationResponse<UserManagementDTO>> getUsers(
            @Parameter(description = "Cursor for pagination") @RequestParam(required = false) Long cursor,
            @Parameter(description = "Number of items per page") @RequestParam(defaultValue = "20") Integer limit,
            @Parameter(description = "Direction of pagination") @RequestParam(defaultValue = "NEXT") String direction) {
        
        log.info("Admin users list requested - cursor: {}, limit: {}, direction: {}", cursor, limit, direction);
        
        CursorPaginationRequest request = CursorPaginationRequest.builder()
                .cursor(cursor)
                .limit(limit)
                .direction(direction)
                .build();
        
        CursorPaginationResponse<UserManagementDTO> response = adminService.getUsersWithCursor(request);
        
        log.info("Users retrieved successfully - count: {}, hasNext: {}, hasPrevious: {}", 
                response.getCount(), response.getHasNext(), response.getHasPrevious());
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/users/search")
    @Operation(
        summary = "Search users by term",
        description = "Search users by username, email, or full name with pagination"
    )
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<CursorPaginationResponse<UserManagementDTO>> searchUsers(
            @Parameter(description = "Search term") @RequestParam String q,
            @Parameter(description = "Cursor for pagination") @RequestParam(required = false) Long cursor,
            @Parameter(description = "Number of items per page") @RequestParam(defaultValue = "20") Integer limit,
            @Parameter(description = "Direction of pagination") @RequestParam(defaultValue = "NEXT") String direction) {
        
        log.info("Admin users search requested - query: {}, cursor: {}, limit: {}", q, cursor, limit);
        
        CursorPaginationRequest request = CursorPaginationRequest.builder()
                .cursor(cursor)
                .limit(limit)
                .direction(direction)
                .build();
        
        CursorPaginationResponse<UserManagementDTO> response = adminService.searchUsers(q, request);
        
        log.info("Users search completed - query: {}, count: {}", q, response.getCount());
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/users/{userId}")
    @Operation(
        summary = "Get user details by ID",
        description = "Get detailed information about a specific user for admin management"
    )
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "User details retrieved successfully"),
        @ApiResponse(responseCode = "404", description = "User not found"),
        @ApiResponse(responseCode = "403", description = "Access denied - admin role required")
    })
    public ResponseEntity<UserManagementDTO> getUserById(
            @Parameter(description = "User ID") @PathVariable Long userId) {
        
        log.info("Admin user details requested for ID: {}", userId);
        
        UserManagementDTO user = adminService.getUserById(userId);
        
        log.info("User details retrieved successfully for ID: {}, username: {}", userId, user.getUsername());
        
        return ResponseEntity.ok(user);
    }
    
    @PutMapping("/users/{userId}/status")
    @Operation(
        summary = "Update user status",
        description = "Update user account status (ACTIVE, INACTIVE, SUSPEND). For SUSPEND status, suspensionDays is required."
    )
    @SecurityRequirement(name = "bearerAuth")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "User status updated successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid status value"),
        @ApiResponse(responseCode = "404", description = "User not found"),
        @ApiResponse(responseCode = "403", description = "Access denied - admin role required")
    })
    public ResponseEntity<StatusUpdateResponse> updateUserStatus(
            @Parameter(description = "User ID") @PathVariable Long userId,
            @Valid @RequestBody UserStatusUpdateRequest request) {
        
        log.info("Admin user status update requested for ID: {} to status: {}", userId, request.getStatus());
        
        StatusUpdateResponse response = adminService.updateUserStatus(userId, request);
        
        log.info("User status updated successfully for ID: {}, new status: {}", userId, response.getNewStatus());
        
        return ResponseEntity.ok(response);
    }
    

} 