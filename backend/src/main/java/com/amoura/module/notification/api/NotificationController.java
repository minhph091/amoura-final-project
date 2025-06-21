package com.amoura.module.notification.api;

import com.amoura.module.notification.dto.CursorPaginationRequest;
import com.amoura.module.notification.dto.CursorPaginationResponse;
import com.amoura.module.notification.dto.NotificationDTO;
import com.amoura.module.notification.service.NotificationService;
import com.amoura.infrastructure.security.JwtTokenProvider.CustomUserDetails;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
@Tag(name = "Notifications", description = "Notification management operations")
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    @Operation(summary = "Get user notifications with cursor-based pagination")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<CursorPaginationResponse<NotificationDTO>> getUserNotifications(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(required = false) Long cursor,
            @RequestParam(defaultValue = "20") Integer limit,
            @RequestParam(defaultValue = "NEXT") String direction) {
        
        CursorPaginationRequest request = CursorPaginationRequest.builder()
                .cursor(cursor)
                .limit(limit)
                .direction(direction)
                .build();
        
        CursorPaginationResponse<NotificationDTO> response = notificationService.getUserNotificationsWithCursor(
                getUserId(userDetails), request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/unread")
    @Operation(summary = "Get unread notifications")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<List<NotificationDTO>> getUnreadNotifications(
            @AuthenticationPrincipal UserDetails userDetails) {
        
        List<NotificationDTO> notifications = notificationService.getUnreadNotifications(
                getUserId(userDetails));
        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/unread/count")
    @Operation(summary = "Get unread notifications count")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Long> getUnreadCount(@AuthenticationPrincipal UserDetails userDetails) {
        Long count = notificationService.getUnreadCount(getUserId(userDetails));
        return ResponseEntity.ok(count);
    }

    @PutMapping("/{notificationId}/read")
    @Operation(summary = "Mark notification as read")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Void> markAsRead(
            @PathVariable Long notificationId,
            @AuthenticationPrincipal UserDetails userDetails) {
        notificationService.markAsRead(notificationId, getUserId(userDetails));
        return ResponseEntity.ok().build();
    }

    @PutMapping("/read-all")
    @Operation(summary = "Mark all notifications as read")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Void> markAllAsRead(@AuthenticationPrincipal UserDetails userDetails) {
        notificationService.markAllAsRead(getUserId(userDetails));
        return ResponseEntity.ok().build();
    }

    private Long getUserId(UserDetails userDetails) {
        if (userDetails instanceof CustomUserDetails) {
            return ((CustomUserDetails) userDetails).getId();
        }
        throw new IllegalArgumentException("UserDetails is not an instance of CustomUserDetails");
    }
} 