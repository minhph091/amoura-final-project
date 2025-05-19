package com.amoura.module.user.dto;
import com.amoura.module.profile.dto.LocationDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateProfileRequest {

    @Min(value = 18, message = "Age must be at least 18")
    @Max(value = 120, message = "Age must be less than 120")
    private Integer age;

    @Min(value = 100, message = "Height must be at least 100cm")
    @Max(value = 250, message = "Height must be less than 250cm")
    private Integer height;

    private String bodyProfile;

    private String sex;

    private String orientation;

    private String job;

    private String drinks;

    private String smokes;

    private String newLanguage;

    private String educationLevel;

    private Boolean dropOut;

    private Integer locationPreference;

    @Size(max = 1000, message = "Bio must be less than 1000 characters")
    private String bio;

    private LocationDTO location;

    private List<String> interests;

    private List<String> languages;

    private List<String> pets;
}