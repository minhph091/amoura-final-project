package com.amoura.module.profile.repository;

import com.amoura.module.profile.domain.Orientation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OrientationRepository extends JpaRepository<Orientation, Long> {
}