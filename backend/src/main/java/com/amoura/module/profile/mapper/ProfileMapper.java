package com.amoura.module.profile.mapper;

import com.amoura.module.profile.domain.*;
import com.amoura.module.profile.dto.*;
import com.amoura.module.user.domain.User;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.Period;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class ProfileMapper {

    @Value("${file.storage.local.base-url}")
    private String baseUrl;

    public ProfileDTO toDTO(User user, Profile profile, Location location,
                          List<Photo> photos, List<UserInterest> interests,
                          List<UserLanguage> languages, List<UserPet> pets) {
        ProfileDTO.ProfileDTOBuilder builder = ProfileDTO.builder()
                .userId(user.getId())
                .username(user.getActualUsername())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .fullName(user.getFullName());

        // Add profile data if exists
        if (profile != null) {
            builder.dateOfBirth(profile.getDateOfBirth());
            if (profile.getDateOfBirth() != null) {
                builder.age(calculateAge(profile.getDateOfBirth()));
            }
            builder.height(profile.getHeight());

            if (profile.getBodyType() != null) {
                builder.bodyType(BodyTypeDTO.builder()
                        .id(profile.getBodyType().getId())
                        .name(profile.getBodyType().getName())
                        .build());
            }

            builder.sex(profile.getSex());

            if (profile.getOrientation() != null) {
                builder.orientation(OrientationDTO.builder()
                        .id(profile.getOrientation().getId())
                        .name(profile.getOrientation().getName())
                        .description(profile.getOrientation().getDescription())
                        .build());
            }

            if (profile.getJobIndustry() != null) {
                builder.jobIndustry(JobIndustryDTO.builder()
                        .id(profile.getJobIndustry().getId())
                        .name(profile.getJobIndustry().getName())
                        .build());
            }

            if (profile.getDrinkStatus() != null) {
                builder.drinkStatus(DrinkStatusDTO.builder()
                        .id(profile.getDrinkStatus().getId())
                        .name(profile.getDrinkStatus().getName())
                        .build());
            }

            if (profile.getSmokeStatus() != null) {
                builder.smokeStatus(SmokeStatusDTO.builder()
                        .id(profile.getSmokeStatus().getId())
                        .name(profile.getSmokeStatus().getName())
                        .build());
            }

            builder.interestedInNewLanguage(profile.getInterestedInNewLanguage());

            if (profile.getEducationLevel() != null) {
                builder.educationLevel(EducationLevelDTO.builder()
                        .id(profile.getEducationLevel().getId())
                        .name(profile.getEducationLevel().getName())
                        .build());
            }

            builder.dropOut(profile.getDropOut());
            builder.locationPreference(profile.getLocationPreference());
            builder.bio(profile.getBio());
        }

        // Add location if exists
        if (location != null) {
            LocationDTO locationDTO = LocationDTO.builder()
                    .latitude(location.getLatitudes() != null ? location.getLatitudes().doubleValue() : null)
                    .longitude(location.getLongitudes() != null ? location.getLongitudes().doubleValue() : null)
                    .country(location.getCountry())
                    .state(location.getState())
                    .city(location.getCity())
                    .build();

            builder.location(locationDTO);
        }

        // Add photos
        if (photos != null && !photos.isEmpty()) {
            List<PhotoDTO> photoDTOs = photos.stream()
                    .map(photo -> PhotoDTO.builder()
                            .id(photo.getId())
                            .url(photo.getPath())
                            .type(photo.getType())
                            .uploadedAt(photo.getCreatedAt())
                            .build())
                    .collect(Collectors.toList());

            builder.photos(photoDTOs);
        }

        // Add interests
        if (interests != null && !interests.isEmpty()) {
            List<InterestDTO> interestDTOs = interests.stream()
                    .map(ui -> InterestDTO.builder()
                            .id(ui.getInterest().getId())
                            .name(ui.getInterest().getName())
                            .build())
                    .collect(Collectors.toList());

            builder.interests(interestDTOs);
        }

        // Add languages
        if (languages != null && !languages.isEmpty()) {
            List<LanguageDTO> languageDTOs = languages.stream()
                    .map(ul -> LanguageDTO.builder()
                            .id(ul.getLanguage().getId())
                            .name(ul.getLanguage().getName())
                            .build())
                    .collect(Collectors.toList());

            builder.languages(languageDTOs);
        }

        // Add pets
        if (pets != null && !pets.isEmpty()) {
            List<PetDTO> petDTOs = pets.stream()
                    .map(up -> PetDTO.builder()
                            .id(up.getPet().getId())
                            .name(up.getPet().getName())
                            .build())
                    .collect(Collectors.toList());

            builder.pets(petDTOs);
        }

        return builder.build();
    }

    public ProfileResponseDTO toProfileResponseDTO(Profile profile, Location location,
                                                 List<Photo> photos, List<UserInterest> interests,
                                                 List<UserLanguage> languages, List<UserPet> pets) {
        ProfileResponseDTO.ProfileResponseDTOBuilder builder = ProfileResponseDTO.builder()
                .userId(profile.getUserId());

        // Add profile data
        builder.dateOfBirth(profile.getDateOfBirth());
        if (profile.getDateOfBirth() != null) {
            builder.age(calculateAge(profile.getDateOfBirth()));
        }
        builder.height(profile.getHeight());

        if (profile.getBodyType() != null) {
            builder.bodyType(BodyTypeDTO.builder()
                    .id(profile.getBodyType().getId())
                    .name(profile.getBodyType().getName())
                    .build());
        }

        builder.sex(profile.getSex());

        if (profile.getOrientation() != null) {
            builder.orientation(OrientationDTO.builder()
                    .id(profile.getOrientation().getId())
                    .name(profile.getOrientation().getName())
                    .description(profile.getOrientation().getDescription())
                    .build());
        }

        if (profile.getJobIndustry() != null) {
            builder.jobIndustry(JobIndustryDTO.builder()
                    .id(profile.getJobIndustry().getId())
                    .name(profile.getJobIndustry().getName())
                    .build());
        }

        if (profile.getDrinkStatus() != null) {
            builder.drinkStatus(DrinkStatusDTO.builder()
                    .id(profile.getDrinkStatus().getId())
                    .name(profile.getDrinkStatus().getName())
                    .build());
        }

        if (profile.getSmokeStatus() != null) {
            builder.smokeStatus(SmokeStatusDTO.builder()
                    .id(profile.getSmokeStatus().getId())
                    .name(profile.getSmokeStatus().getName())
                    .build());
        }

        builder.interestedInNewLanguage(profile.getInterestedInNewLanguage());

        if (profile.getEducationLevel() != null) {
            builder.educationLevel(EducationLevelDTO.builder()
                    .id(profile.getEducationLevel().getId())
                    .name(profile.getEducationLevel().getName())
                    .build());
        }

        builder.dropOut(profile.getDropOut());
        builder.locationPreference(profile.getLocationPreference());
        builder.bio(profile.getBio());

        // Add location if exists
        if (location != null) {
            LocationDTO locationDTO = LocationDTO.builder()
                    .latitude(location.getLatitudes() != null ? location.getLatitudes().doubleValue() : null)
                    .longitude(location.getLongitudes() != null ? location.getLongitudes().doubleValue() : null)
                    .country(location.getCountry())
                    .state(location.getState())
                    .city(location.getCity())
                    .build();

            builder.location(locationDTO);
        }

        // Add photos
        if (photos != null && !photos.isEmpty()) {
            List<PhotoDTO> photoDTOs = photos.stream()
                .map(photo -> {
                    String url = photo.getPath();
                    if (url != null && !url.isEmpty() && !url.startsWith("http")) {
                        url = baseUrl + "/" + url;
                    }
                    return PhotoDTO.builder()
                        .id(photo.getId())
                        .url(url)
                        .type(photo.getType())
                        .uploadedAt(photo.getCreatedAt())
                        .build();
                })
                .collect(Collectors.toList());

            builder.photos(photoDTOs);
        }

        // Add interests
        if (interests != null && !interests.isEmpty()) {
            List<InterestDTO> interestDTOs = interests.stream()
                    .map(ui -> InterestDTO.builder()
                            .id(ui.getInterest().getId())
                            .name(ui.getInterest().getName())
                            .build())
                    .collect(Collectors.toList());

            builder.interests(interestDTOs);
        }

        // Add languages
        if (languages != null && !languages.isEmpty()) {
            List<LanguageDTO> languageDTOs = languages.stream()
                    .map(ul -> LanguageDTO.builder()
                            .id(ul.getLanguage().getId())
                            .name(ul.getLanguage().getName())
                            .build())
                    .collect(Collectors.toList());

            builder.languages(languageDTOs);
        }

        // Add pets
        if (pets != null && !pets.isEmpty()) {
            List<PetDTO> petDTOs = pets.stream()
                    .map(up -> PetDTO.builder()
                            .id(up.getPet().getId())
                            .name(up.getPet().getName())
                            .build())
                    .collect(Collectors.toList());

            builder.pets(petDTOs);
        }

        return builder.build();
    }

    private Integer calculateAge(LocalDate dateOfBirth) {
        if (dateOfBirth == null) {
            return null;
        }
        return Period.between(dateOfBirth, LocalDate.now()).getYears();
    }
}