package com.amoura.module.profile.repository;

import com.amoura.module.profile.domain.Photo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PhotoRepository extends JpaRepository<Photo, Long> {
    List<Photo> findByUserIdAndType(Long userId, String type);
    List<Photo> findByUserId(Long userId);
} 