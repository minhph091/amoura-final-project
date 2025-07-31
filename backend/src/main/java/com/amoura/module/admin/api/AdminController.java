package com.amoura.module.admin.api;

import com.amoura.module.admin.dto.AdminDashboardDTO;
import com.amoura.module.admin.service.AdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
} 