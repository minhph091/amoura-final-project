package com.amoura.module.profile.service;

import com.amoura.module.profile.dto.PhotoDTO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface PhotoService {
    // Avatar methods
    PhotoDTO getUserAvatar(String email);
    PhotoDTO getUserAvatarById(Long userId);
    PhotoDTO uploadAvatar(String email, MultipartFile file);
    void deleteAvatar(String email);

    // Profile cover methods
    PhotoDTO getUserProfileCover(String email);
    PhotoDTO getUserProfileCoverById(Long userId);
    PhotoDTO uploadProfileCover(String email, MultipartFile file);
    void deleteProfileCover(String email);

    // Highlight methods
    List<PhotoDTO> getUserHighlights(String email);
    List<PhotoDTO> getUserHighlightsById(Long userId);
    PhotoDTO uploadHighlight(String email, MultipartFile file);
    void deleteHighlight(String email, Long photoId);

    // All photos methods
    List<PhotoDTO> getAllPhotos(String email);
    List<PhotoDTO> getAllPhotosById(Long userId);
} 