package com.amoura.module.profile.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProfileOptionsDTO {
    private List<OrientationDTO> orientations;
    private List<JobIndustryDTO> jobIndustries;
    private List<DrinkStatusDTO> drinkStatuses;
    private List<SmokeStatusDTO> smokeStatuses;
    private List<EducationLevelDTO> educationLevels;
    private List<PetDTO> pets;
    private List<InterestDTO> interests;
    private List<LanguageDTO> languages;
    private List<BodyTypeDTO> bodyTypes;
} 