package com.amoura.module.matching.api;

import com.amoura.module.matching.dto.SwipeRequest;
import com.amoura.module.matching.dto.SwipeResponse;
import com.amoura.module.matching.dto.UserRecommendationDTO;
import com.amoura.module.matching.service.MatchingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("matching")
@RequiredArgsConstructor
@Tag(name = "Matching", description = "Matching and recommendation operations")
public class MatchingController {

    private final MatchingService matchingService;

    @GetMapping("/recommendations")
    @Operation(summary = "Get recommended users for matching")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<List<UserRecommendationDTO>> getRecommendedUsers(
            @AuthenticationPrincipal UserDetails userDetails) {
        List<UserRecommendationDTO> recommendations = matchingService.getRecommendedUsers(userDetails.getUsername());
        return ResponseEntity.ok(recommendations);
    }

    @PostMapping("/swipe")
    @Operation(summary = "Swipe (like/pass) a user")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<SwipeResponse> swipeUser(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody SwipeRequest request) {
        SwipeResponse response = matchingService.swipeUser(userDetails.getUsername(), request);
        return ResponseEntity.ok(response);
    }
} 