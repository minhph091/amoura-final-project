package com.amoura.module.user.api;

import com.amoura.module.user.service.OnlineUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserStatusController {

    private final OnlineUserService onlineUserService;

    @GetMapping("/{userId}/online")
    public ResponseEntity<Boolean> isUserOnline(@PathVariable Long userId) {
        return ResponseEntity.ok(onlineUserService.isOnline(userId));
    }
} 