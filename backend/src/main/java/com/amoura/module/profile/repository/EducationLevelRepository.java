package com.amoura.module.profile.repository;

import com.amoura.module.profile.domain.EducationLevel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EducationLevelRepository extends JpaRepository<EducationLevel, Long> {
}