package com.amoura.module.user.dto;
import com.amoura.module.profile.dto.LocationDTO;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = false)
public class UpdateProfileRequest {
    private LocalDate dateOfBirth;

    @Min(value = 100, message = "Height must be at least 100cm")
    @Max(value = 250, message = "Height must be less than 250cm")
    private Integer height;

    private Long bodyTypeId;

    private String sex;

    private Long orientationId;

    private Long jobIndustryId;

    private Long drinkStatusId;

    private Long smokeStatusId;

    private Boolean interestedInNewLanguage;

    private Long educationLevelId;

    private Boolean dropOut;

    private Integer locationPreference;

    @Size(max = 1000, message = "Bio must be less than 1000 characters")
    private String bio;

    private LocationDTO location;

    private List<Long> interestIds;

    private List<Long> languageIds;

    private List<Long> petIds;
}