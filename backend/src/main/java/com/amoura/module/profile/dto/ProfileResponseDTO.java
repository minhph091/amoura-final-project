package com.amoura.module.profile.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProfileResponseDTO {
    private Long userId;
    private LocalDate dateOfBirth;
    private Integer age;
    private Integer height;
    private BodyTypeDTO bodyType;
    private String sex;
    private OrientationDTO orientation;
    private JobIndustryDTO jobIndustry;
    private DrinkStatusDTO drinkStatus;
    private SmokeStatusDTO smokeStatus;
    private Boolean interestedInNewLanguage;
    private EducationLevelDTO educationLevel;
    private Boolean dropOut;
    private Integer locationPreference;
    private String bio;
    private LocationDTO location;
    private List<InterestDTO> interests;
    private List<LanguageDTO> languages;
    private List<PetDTO> pets;
    private List<PhotoDTO> photos;
} 