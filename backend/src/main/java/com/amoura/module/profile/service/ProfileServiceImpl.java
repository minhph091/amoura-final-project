package com.amoura.module.profile.service;

import com.amoura.common.exception.ApiException;
import com.amoura.module.profile.domain.*;
import com.amoura.module.profile.dto.*;
import com.amoura.module.profile.mapper.ProfileMapper;
import com.amoura.module.profile.repository.*;
import com.amoura.module.user.domain.User;
import com.amoura.module.user.dto.UpdateProfileRequest;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProfileServiceImpl implements ProfileService {

    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;
    private final BodyTypeRepository bodyTypeRepository;
    private final OrientationRepository orientationRepository;
    private final JobIndustryRepository jobIndustryRepository;
    private final DrinkStatusRepository drinkStatusRepository;
    private final SmokeStatusRepository smokeStatusRepository;
    private final EducationLevelRepository educationLevelRepository;
    private final InterestRepository interestRepository;
    private final LanguageRepository languageRepository;
    private final PetRepository petRepository;
    private final UserInterestRepository userInterestRepository;
    private final UserLanguageRepository userLanguageRepository;
    private final UserPetRepository userPetRepository;
    private final ProfileMapper profileMapper;

    @Override
    @Transactional
    public ProfileDTO updateProfile(String email, UpdateProfileRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        Profile profile = profileRepository.findById(user.getId())
                .orElseGet(() -> Profile.builder().user(user).userId(user.getId()).build());

        // Update basic profile information
        if (request.getAge() != null) {
            profile.setDateOfBirth(LocalDate.now().minusYears(request.getAge()));
        }
        if (request.getHeight() != null) {
            profile.setHeight(request.getHeight());
        }
        if (request.getBodyTypeId() != null) {
            BodyType bodyType = bodyTypeRepository.findById(request.getBodyTypeId())
                    .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Invalid body type", "INVALID_BODY_TYPE"));
            profile.setBodyType(bodyType);
        }
        if (request.getSex() != null) {
            profile.setSex(request.getSex());
        }
        if (request.getOrientationId() != null) {
            Orientation orientation = orientationRepository.findById(request.getOrientationId())
                    .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Invalid orientation", "INVALID_ORIENTATION"));
            profile.setOrientation(orientation);
        }
        if (request.getJobIndustryId() != null) {
            JobIndustry jobIndustry = jobIndustryRepository.findById(request.getJobIndustryId())
                    .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Invalid job industry", "INVALID_JOB_INDUSTRY"));
            profile.setJobIndustry(jobIndustry);
        }
        if (request.getDrinkStatusId() != null) {
            DrinkStatus drinkStatus = drinkStatusRepository.findById(request.getDrinkStatusId())
                    .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Invalid drink status", "INVALID_DRINK_STATUS"));
            profile.setDrinkStatus(drinkStatus);
        }
        if (request.getSmokeStatusId() != null) {
            SmokeStatus smokeStatus = smokeStatusRepository.findById(request.getSmokeStatusId())
                    .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Invalid smoke status", "INVALID_SMOKE_STATUS"));
            profile.setSmokeStatus(smokeStatus);
        }
        if (request.getInterestedInNewLanguage() != null) {
            profile.setInterestedInNewLanguage(request.getInterestedInNewLanguage());
        }
        if (request.getEducationLevelId() != null) {
            EducationLevel educationLevel = educationLevelRepository.findById(request.getEducationLevelId())
                    .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Invalid education level", "INVALID_EDUCATION_LEVEL"));
            profile.setEducationLevel(educationLevel);
        }
        if (request.getDropOut() != null) {
            profile.setDropOut(request.getDropOut());
        }
        if (request.getLocationPreference() != null) {
            profile.setLocationPreference(request.getLocationPreference());
        }
        if (request.getBio() != null) {
            profile.setBio(request.getBio());
        }

        Profile savedProfile = profileRepository.save(profile);

        if (request.getLocation() != null) {
            try {
                Location location = user.getLocation();
                if (location == null) {
                    location = Location.builder()
                            .user(user)
                            .userId(user.getId())
                            .build();
                }
                
                location.setLatitudes(BigDecimal.valueOf(request.getLocation().getLatitude()));
                location.setLongitudes(BigDecimal.valueOf(request.getLocation().getLongitude()));
                location.setCountry(request.getLocation().getCountry());
                location.setState(request.getLocation().getState());
                location.setCity(request.getLocation().getCity());
                
                user.setLocation(location);
                userRepository.save(user);
            } catch (Exception e) {
                log.error("Error updating location for user {}: {}", user.getId(), e.getMessage());
                throw new ApiException(HttpStatus.CONFLICT, "Failed to update location. Please try again.", "LOCATION_UPDATE_FAILED");
            }
        }

        if (request.getInterestIds() != null) {
            userInterestRepository.deleteByUserId(user.getId());
            List<UserInterest> userInterests = new ArrayList<>();
            for (Long interestId : request.getInterestIds()) {
                Interest interest = interestRepository.findById(interestId)
                        .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Invalid interest ID: " + interestId, "INVALID_INTEREST"));
                userInterests.add(UserInterest.builder()
                        .user(user)
                        .interest(interest)
                        .build());
            }
            userInterestRepository.saveAll(userInterests);
        }

        if (request.getLanguageIds() != null) {
            userLanguageRepository.deleteByUserId(user.getId());
            List<UserLanguage> userLanguages = new ArrayList<>();
            for (Long languageId : request.getLanguageIds()) {
                Language language = languageRepository.findById(languageId)
                        .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Invalid language ID: " + languageId, "INVALID_LANGUAGE"));
                userLanguages.add(UserLanguage.builder()
                        .user(user)
                        .language(language)
                        .build());
            }
            userLanguageRepository.saveAll(userLanguages);
        }

        if (request.getPetIds() != null) {
            userPetRepository.deleteByUserId(user.getId());
            List<UserPet> userPets = new ArrayList<>();
            for (Long petId : request.getPetIds()) {
                Pet pet = petRepository.findById(petId)
                        .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Invalid pet ID: " + petId, "INVALID_PET"));
                userPets.add(UserPet.builder()
                        .user(user)
                        .pet(pet)
                        .build());
            }
            userPetRepository.saveAll(userPets);
        }

        List<UserInterest> interests = userInterestRepository.findByUserId(user.getId());
        List<UserLanguage> languages = userLanguageRepository.findByUserId(user.getId());
        List<UserPet> pets = userPetRepository.findByUserId(user.getId());
        List<Photo> photos = user.getPhotos();

        return profileMapper.toDTO(user, savedProfile, user.getLocation(), photos, interests, languages, pets);
    }

    @Override
    @Transactional(readOnly = true)
    public ProfileOptionsDTO getAllProfileOptions() {
        return ProfileOptionsDTO.builder()
                .orientations(orientationRepository.findAll().stream()
                        .map(o -> OrientationDTO.builder()
                                .id(o.getId())
                                .name(o.getName())
                                .description(o.getDescription())
                                .build())
                        .collect(Collectors.toList()))
                .jobIndustries(jobIndustryRepository.findAll().stream()
                        .map(j -> JobIndustryDTO.builder()
                                .id(j.getId())
                                .name(j.getName())
                                .build())
                        .collect(Collectors.toList()))
                .drinkStatuses(drinkStatusRepository.findAll().stream()
                        .map(d -> DrinkStatusDTO.builder()
                                .id(d.getId())
                                .name(d.getName())
                                .build())
                        .collect(Collectors.toList()))
                .smokeStatuses(smokeStatusRepository.findAll().stream()
                        .map(s -> SmokeStatusDTO.builder()
                                .id(s.getId())
                                .name(s.getName())
                                .build())
                        .collect(Collectors.toList()))
                .educationLevels(educationLevelRepository.findAll().stream()
                        .map(e -> EducationLevelDTO.builder()
                                .id(e.getId())
                                .name(e.getName())
                                .build())
                        .collect(Collectors.toList()))
                .pets(petRepository.findAll().stream()
                        .map(p -> PetDTO.builder()
                                .id(p.getId())
                                .name(p.getName())
                                .build())
                        .collect(Collectors.toList()))
                .interests(interestRepository.findAll().stream()
                        .map(i -> InterestDTO.builder()
                                .id(i.getId())
                                .name(i.getName())
                                .build())
                        .collect(Collectors.toList()))
                .languages(languageRepository.findAll().stream()
                        .map(l -> LanguageDTO.builder()
                                .id(l.getId())
                                .name(l.getName())
                                .build())
                        .collect(Collectors.toList()))
                .bodyTypes(bodyTypeRepository.findAll().stream()
                        .map(b -> BodyTypeDTO.builder()
                                .id(b.getId())
                                .name(b.getName())
                                .build())
                        .collect(Collectors.toList()))
                .build();
    }
} 