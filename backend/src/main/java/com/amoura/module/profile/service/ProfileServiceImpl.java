package com.amoura.module.profile.service;

import com.amoura.common.exception.ApiException;
import com.amoura.module.profile.domain.*;
import com.amoura.module.profile.dto.*;
import com.amoura.module.profile.mapper.ProfileMapper;
import com.amoura.module.profile.repository.*;
import com.amoura.module.user.domain.User;
import com.amoura.module.user.dto.UpdateProfileRequest;
import com.amoura.module.profile.dto.LocationDTO;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.function.Function;
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

    private void validateIds(List<Long> ids, String entityName, Function<Long, Boolean> existsCheck) {
        if (ids != null && !ids.isEmpty()) {
            List<Long> invalidIds = ids.stream()
                .filter(id -> !existsCheck.apply(id))
                .toList();
                
            if (!invalidIds.isEmpty()) {
                throw new ApiException(HttpStatus.BAD_REQUEST, 
                    "Invalid " + entityName + " IDs: " + invalidIds, 
                    "INVALID_" + entityName.toUpperCase());
            }
        }
    }

    private void validateLocation(LocationDTO location) {
        if (location != null) {
            if (location.getLatitude() < -90 || location.getLatitude() > 90) {
                throw new ApiException(HttpStatus.BAD_REQUEST, 
                    "Invalid latitude value", "INVALID_LATITUDE");
            }
            if (location.getLongitude() < -180 || location.getLongitude() > 180) {
                throw new ApiException(HttpStatus.BAD_REQUEST, 
                    "Invalid longitude value", "INVALID_LONGITUDE");
            }
        }
    }

    private void validateRequiredFields(UpdateProfileRequest request) {
        // Validate sex if provided
        if (request.getSex() != null) {
            Set<String> validSexValues = Set.of("male", "female", "non-binary", "prefer not to say");
            if (!validSexValues.contains(request.getSex().toLowerCase())) {
                throw new ApiException(HttpStatus.BAD_REQUEST, 
                    "Invalid sex value. Must be one of: " + validSexValues, 
                    "INVALID_SEX");
            }
        }

        // Validate date of birth if provided
        if (request.getDateOfBirth() != null) {
            LocalDate minDate = LocalDate.now().minusYears(18);
            if (request.getDateOfBirth().isAfter(minDate)) {
                throw new ApiException(HttpStatus.BAD_REQUEST, 
                    "User must be at least 18 years old", 
                    "INVALID_DATE_OF_BIRTH");
            }
        }

        // Validate height if provided
        if (request.getHeight() != null) {
            if (request.getHeight() < 100 || request.getHeight() > 250) {
                throw new ApiException(HttpStatus.BAD_REQUEST,
                    "Height must be between 100cm and 250cm",
                    "INVALID_HEIGHT");
            }
        }
    }

    private Map<Long, Interest> getInterestsByIds(List<Long> ids) {
        return interestRepository.findAllById(ids).stream()
            .collect(Collectors.toMap(Interest::getId, Function.identity()));
    }

    private Map<Long, Language> getLanguagesByIds(List<Long> ids) {
        return languageRepository.findAllById(ids).stream()
            .collect(Collectors.toMap(Language::getId, Function.identity()));
    }

    private Map<Long, Pet> getPetsByIds(List<Long> ids) {
        return petRepository.findAllById(ids).stream()
            .collect(Collectors.toMap(Pet::getId, Function.identity()));
    }

    @Override
    @Transactional(readOnly = true)
    public ProfileResponseDTO getProfile(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        Profile profile = profileRepository.findById(user.getId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Profile not found", "PROFILE_NOT_FOUND"));

        List<UserInterest> interests = userInterestRepository.findByUserId(user.getId());
        List<UserLanguage> languages = userLanguageRepository.findByUserId(user.getId());
        List<UserPet> pets = userPetRepository.findByUserId(user.getId());
        List<Photo> photos = user.getPhotos();

        return profileMapper.toProfileResponseDTO(profile, user.getLocation(), photos, interests, languages, pets);
    }

    @Override
    @Transactional
    public ProfileResponseDTO updateProfile(String email, UpdateProfileRequest request) {
        log.debug("Updating profile for user: {}", email);
        log.debug("Received request: {}", request);

        // Check if request is empty
        if (isRequestEmpty(request)) {
            throw new ApiException(HttpStatus.BAD_REQUEST,
                "Request must contain at least one field to update",
                "EMPTY_REQUEST");
        }

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        Profile profile = profileRepository.findById(user.getId())
                .orElseGet(() -> Profile.builder().user(user).userId(user.getId()).build());

        // Validate request
        validateRequiredFields(request);
        validateLocation(request.getLocation());

        // Update basic profile information
        if (request.getDateOfBirth() != null) {
            profile.setDateOfBirth(request.getDateOfBirth());
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
            validateIds(request.getInterestIds(), "interest", interestRepository::existsById);
            userInterestRepository.deleteByUserId(user.getId());
            Map<Long, Interest> interests = getInterestsByIds(request.getInterestIds());
            List<UserInterest> userInterests = new ArrayList<>();
            for (Long interestId : request.getInterestIds()) {
                Interest interest = interests.get(interestId);
                UserInterest.UserInterestId userInterestId = new UserInterest.UserInterestId(user.getId(), interestId);
                userInterests.add(UserInterest.builder()
                        .id(userInterestId)
                        .user(user)
                        .interest(interest)
                        .build());
            }
            userInterestRepository.saveAll(userInterests);
        }

        if (request.getLanguageIds() != null) {
            validateIds(request.getLanguageIds(), "language", languageRepository::existsById);
            userLanguageRepository.deleteByUserId(user.getId());
            Map<Long, Language> languages = getLanguagesByIds(request.getLanguageIds());
            List<UserLanguage> userLanguages = new ArrayList<>();
            for (Long languageId : request.getLanguageIds()) {
                Language language = languages.get(languageId);
                UserLanguage.UserLanguageId userLanguageId = new UserLanguage.UserLanguageId(user.getId(), languageId);
                userLanguages.add(UserLanguage.builder()
                        .id(userLanguageId)
                        .user(user)
                        .language(language)
                        .build());
            }
            userLanguageRepository.saveAll(userLanguages);
        }

        if (request.getPetIds() != null) {
            validateIds(request.getPetIds(), "pet", petRepository::existsById);
            userPetRepository.deleteByUserId(user.getId());
            Map<Long, Pet> pets = getPetsByIds(request.getPetIds());
            List<UserPet> userPets = new ArrayList<>();
            for (Long petId : request.getPetIds()) {
                Pet pet = pets.get(petId);
                UserPet.UserPetId userPetId = new UserPet.UserPetId(user.getId(), petId);
                userPets.add(UserPet.builder()
                        .id(userPetId)
                        .user(user)
                        .pet(pet)
                        .build());
            }
            userPetRepository.saveAll(userPets);
        }

        // Refresh data from database to ensure we have the latest state
        List<UserInterest> interests = userInterestRepository.findByUserId(user.getId());
        List<UserLanguage> languages = userLanguageRepository.findByUserId(user.getId());
        List<UserPet> pets = userPetRepository.findByUserId(user.getId());
        List<Photo> photos = user.getPhotos();

        // Use toProfileResponseDTO instead of toDTO to match the GET /me endpoint
        return profileMapper.toProfileResponseDTO(savedProfile, user.getLocation(), photos, interests, languages, pets);
    }

    private boolean isRequestEmpty(UpdateProfileRequest request) {
        return request.getDateOfBirth() == null &&
               request.getHeight() == null &&
               request.getBodyTypeId() == null &&
               request.getSex() == null &&
               request.getOrientationId() == null &&
               request.getJobIndustryId() == null &&
               request.getDrinkStatusId() == null &&
               request.getSmokeStatusId() == null &&
               request.getInterestedInNewLanguage() == null &&
               request.getEducationLevelId() == null &&
               request.getDropOut() == null &&
               request.getLocationPreference() == null &&
               request.getBio() == null &&
               request.getLocation() == null &&
               (request.getInterestIds() == null || request.getInterestIds().isEmpty()) &&
               (request.getLanguageIds() == null || request.getLanguageIds().isEmpty()) &&
               (request.getPetIds() == null || request.getPetIds().isEmpty());
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