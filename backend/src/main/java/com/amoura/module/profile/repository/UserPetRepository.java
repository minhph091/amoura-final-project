package com.amoura.module.profile.repository;

import com.amoura.module.profile.domain.UserPet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserPetRepository extends JpaRepository<UserPet, UserPet.UserPetId> {
    List<UserPet> findByUserId(Long userId);
    void deleteByUserId(Long userId);
} 