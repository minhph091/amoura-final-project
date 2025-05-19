package com.amoura.module.profile.repository;

import com.amoura.module.profile.domain.BodyType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BodyTypeRepository extends JpaRepository<BodyType, Long> {
}