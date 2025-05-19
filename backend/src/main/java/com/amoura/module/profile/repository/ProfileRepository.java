package com.amoura.module.profile.repository;

import com.amoura.module.profile.domain.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ProfileRepository extends JpaRepository<Profile, Long> {

    @Query("SELECT p FROM Profile p WHERE p.dateOfBirth BETWEEN :startDate AND :endDate")
    List<Profile> findByDateOfBirthBetween(LocalDate startDate, LocalDate endDate);

    @Query("SELECT p FROM Profile p WHERE " +
            "(:sex IS NULL OR p.sex = :sex) AND " +
            "(:bodyTypeId IS NULL OR p.bodyType.id = :bodyTypeId) AND " +
            "(:orientationId IS NULL OR p.orientation.id = :orientationId) AND " +
            "(:minHeight IS NULL OR p.height >= :minHeight) AND " +
            "(:maxHeight IS NULL OR p.height <= :maxHeight)")
    List<Profile> findMatchingProfiles(String sex, Long bodyTypeId, Long orientationId,
                                       Integer minHeight, Integer maxHeight);

    @Query(value = "SELECT DATE_PART('year', AGE(CURRENT_DATE, date_of_birth)) FROM profile WHERE user_id = :userId", nativeQuery = true)
    Integer calculateAge(Long userId);

    @Query(value = "SELECT * FROM profile WHERE DATE_PART('year', AGE(CURRENT_DATE, date_of_birth)) BETWEEN :minAge AND :maxAge", nativeQuery = true)
    List<Profile> findByAgeBetween(Integer minAge, Integer maxAge);

}
