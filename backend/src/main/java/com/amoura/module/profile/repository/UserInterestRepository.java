package com.amoura.module.profile.repository;

import com.amoura.module.profile.domain.UserInterest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserInterestRepository extends JpaRepository<UserInterest, UserInterest.UserInterestId> {
    List<UserInterest> findByUserId(Long userId);
    void deleteByUserId(Long userId);
} 