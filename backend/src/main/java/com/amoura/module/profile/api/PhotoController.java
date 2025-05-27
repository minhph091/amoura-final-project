package com.amoura.module.profile.api;

import com.amoura.module.profile.dto.PhotoDTO;
import com.amoura.module.profile.service.PhotoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/profiles/photos")
@RequiredArgsConstructor
@Tag(name = "Profile Photos", description = "Profile photo management operations")
public class PhotoController {

    private final PhotoService photoService;

    // Avatar endpoints
    @GetMapping("/avatar")
    @Operation(summary = "Get current user's avatar")
    @SecurityRequirement(name = "bearerAuth")

    public ResponseEntity<PhotoDTO> getMyAvatar(
            @AuthenticationPrincipal UserDetails userDetails) {
        PhotoDTO avatar = photoService.getUserAvatar(userDetails != null ? userDetails.getUsername() : null);
        return ResponseEntity.ok(avatar);
    }

    @PostMapping(value = "/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload avatar")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<PhotoDTO> uploadAvatar(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam("file") MultipartFile file) {
        PhotoDTO avatar = photoService.uploadAvatar(userDetails.getUsername(), file);
        return ResponseEntity.ok(avatar);
    }

    @DeleteMapping("/avatar")
    @Operation(summary = "Delete avatar")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Void> deleteAvatar(
            @AuthenticationPrincipal UserDetails userDetails) {
        photoService.deleteAvatar(userDetails.getUsername());
        return ResponseEntity.ok().build();
    }

    // Profile cover endpoints
    @GetMapping("/cover")
    @Operation(summary = "Get current user's profile cover")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<PhotoDTO> getMyProfileCover(
            @AuthenticationPrincipal UserDetails userDetails) {
        PhotoDTO cover = photoService.getUserProfileCover(userDetails != null ? userDetails.getUsername() : null);
        return ResponseEntity.ok(cover);
    }

    @PostMapping(value = "/cover", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload profile cover")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<PhotoDTO> uploadProfileCover(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam("file") MultipartFile file) {
        PhotoDTO cover = photoService.uploadProfileCover(userDetails.getUsername(), file);
        return ResponseEntity.ok(cover);
    }

    @DeleteMapping("/cover")
    @Operation(summary = "Delete profile cover")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Void> deleteProfileCover(
            @AuthenticationPrincipal UserDetails userDetails) {
        photoService.deleteProfileCover(userDetails.getUsername());
        return ResponseEntity.ok().build();
    }

    // Highlight photos endpoints
    @GetMapping("/highlights")
    @Operation(summary = "Get current user's highlight photos")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<List<PhotoDTO>> getMyHighlights(
            @AuthenticationPrincipal UserDetails userDetails) {
        List<PhotoDTO> highlights = photoService.getUserHighlights(userDetails != null ? userDetails.getUsername() : null);
        return ResponseEntity.ok(highlights);
    }

    @PostMapping(value = "/highlights", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload a highlight photo")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<PhotoDTO> uploadHighlight(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam("file") MultipartFile file) {
        PhotoDTO highlight = photoService.uploadHighlight(userDetails.getUsername(), file);
        return ResponseEntity.ok(highlight);
    }

    @DeleteMapping("/highlights/{photoId}")
    @Operation(summary = "Delete a highlight photo")
    @SecurityRequirement(name = "bearerAuth")
    public ResponseEntity<Void> deleteHighlight(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable Long photoId) {
        photoService.deleteHighlight(userDetails.getUsername(), photoId);
        return ResponseEntity.ok().build();
    }

    // Public endpoints to view other users' photos
    @GetMapping("/{userId}/avatar")
    @Operation(summary = "Get a user's avatar")
    public ResponseEntity<PhotoDTO> getUserAvatar(@PathVariable Long userId) {
        PhotoDTO avatar = photoService.getUserAvatarById(userId);
        return ResponseEntity.ok(avatar);
    }

    @GetMapping("/{userId}/cover")
    @Operation(summary = "Get a user's profile cover")
    public ResponseEntity<PhotoDTO> getUserProfileCover(@PathVariable Long userId) {
        PhotoDTO cover = photoService.getUserProfileCoverById(userId);
        return ResponseEntity.ok(cover);
    }

    @GetMapping("/{userId}/highlights")
    @Operation(summary = "Get a user's highlight photos")
    public ResponseEntity<List<PhotoDTO>> getUserHighlights(@PathVariable Long userId) {
        List<PhotoDTO> highlights = photoService.getUserHighlightsById(userId);
        return ResponseEntity.ok(highlights);
    }

    // All photos endpoints
    @GetMapping
    @Operation(summary = "Get all photos of current user")
    @SecurityRequirement(name = "bearerAuth")

    public ResponseEntity<List<PhotoDTO>> getAllMyPhotos(
            @AuthenticationPrincipal UserDetails userDetails) {
        List<PhotoDTO> photos = photoService.getAllPhotos(userDetails != null ? userDetails.getUsername() : null);
        return ResponseEntity.ok(photos);
    }

    @GetMapping("/{userId}")
    @Operation(summary = "Get all photos of a specific user")
    public ResponseEntity<List<PhotoDTO>> getAllUserPhotos(@PathVariable Long userId) {
        List<PhotoDTO> photos = photoService.getAllPhotosById(userId);
        return ResponseEntity.ok(photos);
    }
} 