package com.amoura.module.profile.repository;

import com.amoura.module.profile.domain.UserLanguage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserLanguageRepository extends JpaRepository<UserLanguage, UserLanguage.UserLanguageId> {
    List<UserLanguage> findByUserId(Long userId);
    void deleteByUserId(Long userId);
} 