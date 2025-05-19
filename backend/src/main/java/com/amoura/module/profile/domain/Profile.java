package com.amoura.module.profile.domain;

import com.amoura.module.user.domain.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "profiles")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor

public class Profile {

    @Id
    @Column(name = "user_id")
    private Long userId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    private Integer height;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "body_type_id")
    private BodyType bodyType;

    private String sex; // male, female

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "orientation_id")
    private Orientation orientation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "job_industry_id")
    private JobIndustry jobIndustry;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "drink_status_id")
    private DrinkStatus drinkStatus;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "smoke_status_id")
    private SmokeStatus smokeStatus;

    @Column(name = "interested_in_new_language")
    private Boolean interestedInNewLanguage;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "education_level_id")
    private EducationLevel educationLevel;

    @Column(name = "drop_out")
    private Boolean dropOut;

    @Column(name = "location_preference")
    private Integer locationPreference;

    @Column(name = "bio", columnDefinition = "text")
    private String bio;

    @Version
    private Integer version;
}