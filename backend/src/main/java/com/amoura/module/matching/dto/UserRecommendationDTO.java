package com.amoura.module.matching.dto;

import com.amoura.module.profile.dto.InterestDTO;
import com.amoura.module.profile.dto.PetDTO;
import com.amoura.module.profile.dto.PhotoDTO;
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
public class UserRecommendationDTO {
    private Long userId;
    private String username;
    private String firstName;
    private String lastName;
    private LocalDate dateOfBirth;
    private Integer age;
    private Integer height;
    private String sex;
    private String bio;
    private String location;
    private Double latitude;
    private Double longitude;
    private List<InterestDTO> interests;
    private List<PetDTO> pets;
    private List<PhotoDTO> photos;
} 