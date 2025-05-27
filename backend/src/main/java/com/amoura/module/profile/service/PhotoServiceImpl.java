package com.amoura.module.profile.service;

import com.amoura.common.exception.ApiException;
import com.amoura.module.profile.domain.Photo;
import com.amoura.module.profile.dto.PhotoDTO;
import com.amoura.module.profile.repository.PhotoRepository;
import com.amoura.module.user.domain.User;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class PhotoServiceImpl implements PhotoService {

    private final UserRepository userRepository;
    private final PhotoRepository photoRepository;

    @Value("${file.storage.local.upload-dir}")
    private String uploadDir;

    @Value("${file.storage.local.base-url}")
    private String baseUrl;

    // Photo limits
    private static final int MAX_AVATAR = 1;
    private static final int MAX_PROFILE_COVER = 1;
    private static final int MAX_HIGHLIGHTS = 4;

    // Avatar methods
    @Override
    @Transactional(readOnly = true)
    public PhotoDTO getUserAvatar(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));
        return getUserAvatarById(user.getId());
    }

    @Override
    @Transactional(readOnly = true)
    public PhotoDTO getUserAvatarById(Long userId) {
        return photoRepository.findByUserIdAndType(userId, "avatar")
                .stream()
                .findFirst()
                .map(this::toDTO)
                .orElse(null);
    }

    @Override
    @Transactional
    public PhotoDTO uploadAvatar(String email, MultipartFile file) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));
        
        // Check avatar limit
        List<Photo> existingAvatars = photoRepository.findByUserIdAndType(user.getId(), "avatar");
        if (existingAvatars.size() >= MAX_AVATAR) {
            throw new ApiException(HttpStatus.BAD_REQUEST, 
                "Maximum number of avatar photos reached (1)", 
                "MAX_AVATAR_REACHED");
        }

        return uploadPhoto(user, file, "avatar");
    }

    @Override
    @Transactional
    public void deleteAvatar(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));
        deletePhotoByType(user, "avatar");
    }

    // Profile cover methods
    @Override
    @Transactional(readOnly = true)
    public PhotoDTO getUserProfileCover(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));
        return getUserProfileCoverById(user.getId());
    }

    @Override
    @Transactional(readOnly = true)
    public PhotoDTO getUserProfileCoverById(Long userId) {
        return photoRepository.findByUserIdAndType(userId, "profile_cover")
                .stream()
                .findFirst()
                .map(this::toDTO)
                .orElse(null);
    }

    @Override
    @Transactional
    public PhotoDTO uploadProfileCover(String email, MultipartFile file) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));
        
        // Check profile cover limit
        List<Photo> existingCovers = photoRepository.findByUserIdAndType(user.getId(), "profile_cover");
        if (existingCovers.size() >= MAX_PROFILE_COVER) {
            throw new ApiException(HttpStatus.BAD_REQUEST, 
                "Maximum number of profile cover photos reached (1)", 
                "MAX_PROFILE_COVER_REACHED");
        }

        return uploadPhoto(user, file, "profile_cover");
    }

    @Override
    @Transactional
    public void deleteProfileCover(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));
        deletePhotoByType(user, "profile_cover");
    }

    // Highlight methods
    @Override
    @Transactional(readOnly = true)
    public List<PhotoDTO> getUserHighlights(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));
        return getUserHighlightsById(user.getId());
    }

    @Override
    @Transactional(readOnly = true)
    public List<PhotoDTO> getUserHighlightsById(Long userId) {
        return photoRepository.findByUserIdAndType(userId, "highlight")
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public PhotoDTO uploadHighlight(String email, MultipartFile file) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));
        
        // Check highlight limit
        List<Photo> existingHighlights = photoRepository.findByUserIdAndType(user.getId(), "highlight");
        if (existingHighlights.size() >= MAX_HIGHLIGHTS) {
            throw new ApiException(HttpStatus.BAD_REQUEST, 
                "Maximum number of highlight photos reached (4)", 
                "MAX_HIGHLIGHTS_REACHED");
        }

        return uploadPhoto(user, file, "highlight");
    }

    @Override
    @Transactional
    public void deleteHighlight(String email, Long photoId) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));
        
        Photo photo = photoRepository.findById(photoId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Photo not found", "PHOTO_NOT_FOUND"));

        if (!photo.getUser().getId().equals(user.getId()) || !"highlight".equals(photo.getType())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Not authorized to delete this photo", "NOT_AUTHORIZED");
        }

        deletePhoto(photo);
    }

    // All photos methods
    @Override
    @Transactional(readOnly = true)
    public List<PhotoDTO> getAllPhotos(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));
        return getAllPhotosById(user.getId());
    }

    @Override
    @Transactional(readOnly = true)
    public List<PhotoDTO> getAllPhotosById(Long userId) {
        if (!userRepository.existsById(userId)) {
            throw new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND");
        }
        return photoRepository.findByUserId(userId)
                .stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    // Helper methods
    private PhotoDTO uploadPhoto(User user, MultipartFile file, String type) {
        // Validate file
        if (file.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "File is empty", "EMPTY_FILE");
        }

        // Validate file type
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "File must be an image", "INVALID_FILE_TYPE");
        }

        try {
            // Create user directory if it doesn't exist
            Path userDir = Paths.get(uploadDir, "users", user.getId().toString());
            if (!Files.exists(userDir)) {
                Files.createDirectories(userDir);
            }

            // Generate filename based on type
            String filename;
            if ("highlight".equals(type)) {
                // For highlights, append a number
                int highlightCount = (int) photoRepository.findByUserIdAndType(user.getId(), type).size();
                filename = "highlight" + (highlightCount + 1) + getFileExtension(file.getOriginalFilename());
            } else {
                // For avatar and profile_cover, use the type as filename
                filename = type + getFileExtension(file.getOriginalFilename());
            }

            Path filePath = userDir.resolve(filename);

            // If file exists, delete it (for avatar and profile_cover)
            if (Files.exists(filePath)) {
                Files.delete(filePath);
            }

            // Save file
            Files.copy(file.getInputStream(), filePath);

            // Create photo record with correct URL path
            String relativePath = "users/" + user.getId() + "/" + filename;
            Photo photo = Photo.builder()
                    .user(user)
                    .path(baseUrl + "/" + relativePath)
                    .type(type)
                    .build();

            Photo savedPhoto = photoRepository.save(photo);
            return toDTO(savedPhoto);

        } catch (IOException e) {
            log.error("Failed to upload photo for user {}: {}", user.getId(), e.getMessage());
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, 
                "Failed to upload photo", "UPLOAD_FAILED");
        }
    }

    private void deletePhotoByType(User user, String type) {
        List<Photo> photos = photoRepository.findByUserIdAndType(user.getId(), type);
        for (Photo photo : photos) {
            deletePhoto(photo);
        }
    }

    private void deletePhoto(Photo photo) {
        try {
            // Delete file from storage
            String relativePath = photo.getPath().substring(baseUrl.length() + 1);
            Path filePath = Paths.get(uploadDir, relativePath);
            Files.deleteIfExists(filePath);

            // Delete photo record
            photoRepository.delete(photo);
        } catch (IOException e) {
            log.error("Failed to delete photo {} for user {}: {}", 
                photo.getId(), photo.getUser().getId(), e.getMessage());
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, 
                "Failed to delete photo", "DELETE_FAILED");
        }
    }

    private PhotoDTO toDTO(Photo photo) {
        return PhotoDTO.builder()
                .id(photo.getId())
                .url(photo.getPath())
                .type(photo.getType())
                .uploadedAt(photo.getCreatedAt())
                .build();
    }

    private String getFileExtension(String filename) {
        if (filename == null) return ".jpg";
        int lastDotIndex = filename.lastIndexOf(".");
        return lastDotIndex == -1 ? ".jpg" : filename.substring(lastDotIndex);
    }
} 