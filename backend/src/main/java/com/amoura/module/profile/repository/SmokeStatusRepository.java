package com.amoura.module.profile.repository;

import com.amoura.module.profile.domain.SmokeStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SmokeStatusRepository extends JpaRepository<SmokeStatus, Long> {
}