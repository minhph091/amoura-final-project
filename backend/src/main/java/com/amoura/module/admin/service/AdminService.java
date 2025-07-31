package com.amoura.module.admin.service;

import com.amoura.module.admin.dto.AdminDashboardDTO;
import com.amoura.module.admin.dto.CursorPaginationRequest;
import com.amoura.module.admin.dto.CursorPaginationResponse;
import com.amoura.module.admin.dto.UserManagementDTO;
import com.amoura.module.admin.dto.UserStatusUpdateRequest;

public interface AdminService {
 
    /**
     * Get admin dashboard overview with system statistics and chart data
     */
    AdminDashboardDTO getDashboardOverview();
    
    /**
     * Get users with cursor pagination for admin management
     */
    CursorPaginationResponse<UserManagementDTO> getUsersWithCursor(CursorPaginationRequest request);
    
    /**
     * Search users by term with pagination
     */
    CursorPaginationResponse<UserManagementDTO> searchUsers(String searchTerm, CursorPaginationRequest request);
    
    /**
     * Get user details by ID for admin management
     */
    UserManagementDTO getUserById(Long userId);
    
    /**
     * Update user status (ACTIVE, INACTIVE, SUSPEND)
     */
    UserManagementDTO updateUserStatus(Long userId, UserStatusUpdateRequest request);
    

} 