package com.amoura.module.profile.repository;

import com.amoura.module.profile.domain.DrinkStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DrinkStatusRepository extends JpaRepository<DrinkStatus, Long> {
}