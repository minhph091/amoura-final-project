package com.amoura.module.profile.repository;

import com.amoura.module.profile.domain.JobIndustry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JobIndustryRepository extends JpaRepository<JobIndustry, Long> {
}