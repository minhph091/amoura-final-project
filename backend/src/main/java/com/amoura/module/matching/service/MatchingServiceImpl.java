package com.amoura.module.matching.service;

import com.amoura.common.exception.ApiException;
import com.amoura.module.matching.domain.Match;
import com.amoura.module.matching.domain.Swipe;
import com.amoura.module.matching.dto.SwipeRequest;
import com.amoura.module.matching.dto.SwipeResponse;
import com.amoura.module.matching.dto.UserRecommendationDTO;
import com.amoura.module.matching.repository.MatchRepository;
import com.amoura.module.matching.repository.SwipeRepository;
import com.amoura.module.profile.domain.Photo;
import com.amoura.module.profile.dto.InterestDTO;
import com.amoura.module.profile.dto.PetDTO;
import com.amoura.module.profile.dto.PhotoDTO;
import com.amoura.module.profile.domain.Profile;
import com.amoura.module.profile.repository.ProfileRepository;
import com.amoura.module.profile.repository.UserInterestRepository;
import com.amoura.module.profile.repository.UserPetRepository;
import com.amoura.module.user.domain.User;
import com.amoura.module.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.annotation.Isolation;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MatchingServiceImpl implements MatchingService {

    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;
    private final SwipeRepository swipeRepository;
    private final MatchRepository matchRepository;
    private final UserInterestRepository userInterestRepository;
    private final UserPetRepository userPetRepository;

    @Override
    @Transactional(readOnly = true)
    public List<UserRecommendationDTO> getRecommendedUsers(String userEmail) {
        User currentUser = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        // Lấy danh sách tất cả người dùng khác (trừ người dùng hiện tại)
        List<User> allUsers = userRepository.findAll().stream()
                .filter(user -> !user.getId().equals(currentUser.getId()))
                .collect(Collectors.toList());

        // Lọc ra những người dùng chưa được swipe
        List<Long> swipedUserIds = swipeRepository.findByInitiatorId(currentUser.getId())
                .stream()
                .map(swipe -> swipe.getTargetUser().getId())
                .collect(Collectors.toList());

        // Lọc ra những người dùng đã match
        List<Long> matchedUserIds = matchRepository.findActiveMatchesByUserId(currentUser.getId())
                .stream()
                .map(match -> {
                    if (match.getUser1().getId().equals(currentUser.getId())) {
                        return match.getUser2().getId();
                    } else {
                        return match.getUser1().getId();
                    }
                })
                .collect(Collectors.toList());

        List<User> availableUsers = allUsers.stream()
                .filter(user -> !swipedUserIds.contains(user.getId()) && !matchedUserIds.contains(user.getId()))
                .collect(Collectors.toList());

        // Chuyển đổi thành DTO
        return availableUsers.stream()
                .map(this::convertToUserRecommendationDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public SwipeResponse swipeUser(String userEmail, SwipeRequest request) {
        User initiator = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        User targetUser = userRepository.findById(request.getTargetUserId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Target user not found", "TARGET_USER_NOT_FOUND"));

        // Kiểm tra không thể swipe chính mình
        if (initiator.getId().equals(targetUser.getId())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Cannot swipe yourself", "INVALID_SWIPE");
        }

        // Kiểm tra xem đã match với nhau chưa
        Optional<Match> existingMatch = matchRepository.findActiveMatchByUserIds(initiator.getId(), targetUser.getId());
        if (existingMatch.isPresent()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "You have already matched with this user", "ALREADY_MATCHED");
        }

        // Kiểm tra đã swipe trước đó chưa
        Optional<Swipe> existingSwipeOpt = swipeRepository.findByInitiatorAndTargetUser(initiator.getId(), targetUser.getId());
        if (existingSwipeOpt.isPresent()) {
            Swipe existingSwipe = existingSwipeOpt.get();
            // Kiểm tra thời gian tạo swipe
            if (existingSwipe.getCreatedAt() != null &&
                existingSwipe.getCreatedAt().isAfter(java.time.LocalDateTime.now().minusHours(1))) {
                // Cho phép update is_like
                existingSwipe.setIsLike(request.getIsLike());
                Swipe updatedSwipe = swipeRepository.save(existingSwipe);
                // Nếu là like, kiểm tra có match không
                if (request.getIsLike()) {
                    return handleLikeSwipe(initiator, targetUser, updatedSwipe);
                }
                // Nếu là pass, chỉ trả về swipeId và isMatch
                return SwipeResponse.builder()
                        .swipeId(updatedSwipe.getId())
                        .isMatch(false)
                        .build();
            } else {
                throw new ApiException(HttpStatus.BAD_REQUEST, "Already swiped this user more than 1 hour ago", "ALREADY_SWIPED");
            }
        }

        // Tạo swipe mới
        Swipe swipe = Swipe.builder()
                .initiator(initiator)
                .targetUser(targetUser)
                .isLike(request.getIsLike())
                .build();

        Swipe savedSwipe = swipeRepository.save(swipe);

        // Nếu là like, kiểm tra có match không
        if (request.getIsLike()) {
            return handleLikeSwipe(initiator, targetUser, savedSwipe);
        }

        // Nếu là pass, chỉ trả về swipeId và isMatch
        return SwipeResponse.builder()
                .swipeId(savedSwipe.getId())
                .isMatch(false)
                .build();
    }

    private SwipeResponse handleLikeSwipe(User initiator, User targetUser, Swipe swipe) {
        // Kiểm tra xem target user đã like initiator chưa
        Optional<Swipe> targetUserLike = swipeRepository.findLikeByInitiatorAndTargetUser(targetUser.getId(), initiator.getId());

        if (targetUserLike.isPresent()) {
            // Có match
            return createMatch(initiator, targetUser, swipe);
        }

        // Chưa có match, chỉ trả về swipeId và isMatch
        return SwipeResponse.builder()
                .swipeId(swipe.getId())
                .isMatch(false)
                .build();
    }

    @Transactional(isolation = Isolation.SERIALIZABLE)
    private SwipeResponse createMatch(User userA, User userB, Swipe swipe) {
        // Kiểm tra xem match đã tồn tại chưa
        Optional<Match> existingMatch = matchRepository.findActiveMatchByUserIds(userA.getId(), userB.getId());
        if (existingMatch.isPresent()) {
            Match match = existingMatch.get();
            String matchMessage = String.format("You and %s have matched! Start chatting now!", userB.getUsername());
            
            return SwipeResponse.builder()
                    .swipeId(swipe.getId())
                    .isMatch(true)
                    .matchId(match.getId())
                    .matchedUserId(userB.getId())
                    .matchedUsername(userB.getUsername())
                    .matchMessage(matchMessage)
                    .build();
        }

        // Tạo match mới
        Match match = Match.builder()
                .user1(userA)
                .user2(userB)
                .status(Match.MatchStatus.active)
                .build();

        Match savedMatch = matchRepository.save(match);

        String matchMessage = String.format("You and %s have matched! Start chatting now!", userB.getUsername());

        return SwipeResponse.builder()
                .swipeId(swipe.getId())
                .isMatch(true)
                .matchId(savedMatch.getId())
                .matchedUserId(userB.getId())
                .matchedUsername(userB.getUsername())
                .matchMessage(matchMessage)
                .build();
    }

    private UserRecommendationDTO convertToUserRecommendationDTO(User user) {
        Profile profile = profileRepository.findById(user.getId()).orElse(null);
        
        List<PhotoDTO> photos = user.getPhotos().stream()
                .map(this::convertToPhotoDTO)
                .collect(Collectors.toList());

        Integer age = null;
        if (profile != null && profile.getDateOfBirth() != null) {
            age = Period.between(profile.getDateOfBirth(), LocalDate.now()).getYears();
        }

        String location = "Unknown";
        Double latitude = null;
        Double longitude = null;
        
        if (user.getLocation() != null) {
            location = String.format("%s, %s", 
                    user.getLocation().getCity() != null ? user.getLocation().getCity() : "",
                    user.getLocation().getCountry() != null ? user.getLocation().getCountry() : "");
            
            if (user.getLocation().getLatitudes() != null) {
                latitude = user.getLocation().getLatitudes().doubleValue();
            }
            if (user.getLocation().getLongitudes() != null) {
                longitude = user.getLocation().getLongitudes().doubleValue();
            }
        }

        // Lấy danh sách sở thích
        List<InterestDTO> interests = userInterestRepository.findByUserId(user.getId())
                .stream()
                .map(userInterest -> InterestDTO.builder()
                        .id(userInterest.getInterest().getId())
                        .name(userInterest.getInterest().getName())
                        .build())
                .collect(Collectors.toList());

        // Lấy danh sách pets
        List<PetDTO> pets = userPetRepository.findByUserId(user.getId())
                .stream()
                .map(userPet -> PetDTO.builder()
                        .id(userPet.getPet().getId())
                        .name(userPet.getPet().getName())
                        .build())
                .collect(Collectors.toList());

        return UserRecommendationDTO.builder()
                .userId(user.getId())
                .username(user.getActualUsername())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .dateOfBirth(profile != null ? profile.getDateOfBirth() : null)
                .age(age)
                .height(profile != null ? profile.getHeight() : null)
                .sex(profile != null ? profile.getSex() : null)
                .bio(profile != null ? profile.getBio() : null)
                .location(location)
                .latitude(latitude)
                .longitude(longitude)
                .interests(interests)
                .pets(pets)
                .photos(photos)
                .build();
    }

    private PhotoDTO convertToPhotoDTO(Photo photo) {
        return PhotoDTO.builder()
                .id(photo.getId())
                .url(photo.getPath())
                .type(photo.getType())
                .uploadedAt(photo.getCreatedAt())
                .build();
    }
} 