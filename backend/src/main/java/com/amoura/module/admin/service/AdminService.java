package com.amoura.module.admin.service;

import com.amoura.module.admin.dto.AdminDashboardDTO;

public interface AdminService {
 
    /**
     * Get admin dashboard overview with system statistics and chart data
     */
    AdminDashboardDTO getDashboardOverview();
} 