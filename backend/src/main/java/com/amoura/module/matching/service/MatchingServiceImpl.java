package com.amoura.module.matching.service;

import com.amoura.common.exception.ApiException;
import com.amoura.module.chat.dto.ChatRoomDTO;
import com.amoura.module.chat.service.ChatService;
import com.amoura.module.matching.domain.Match;
import com.amoura.module.matching.domain.Swipe;
import com.amoura.module.matching.dto.ReceivedLikeDTO;
import com.amoura.module.matching.dto.SwipeRequest;
import com.amoura.module.matching.dto.SwipeResponse;
import com.amoura.module.matching.dto.UserRecommendationDTO;
import com.amoura.module.matching.repository.MatchRepository;
import com.amoura.module.matching.repository.SwipeRepository;
import com.amoura.module.notification.service.NotificationService;
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

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.util.Collections;
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
    private final NotificationService notificationService;
    private final ChatService chatService;
    private final AIServiceClient aiServiceClient;

    @Override
    @Transactional(readOnly = true)
    public List<UserRecommendationDTO> getRecommendedUsers(String userEmail) {
        User currentUser = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        // Try to get AI-powered recommendations first
        List<Long> aiRecommendedUserIds = Collections.emptyList();
        try {
            if (aiServiceClient.isAIServiceAvailable()) {
                log.info("Using AI service for recommendations for user: {}", currentUser.getId());
                aiRecommendedUserIds = aiServiceClient.getPotentialMatches(currentUser.getId(), 20);
            } else {
                log.warn("AI service is not available, falling back to basic recommendations");
            }
        } catch (Exception e) {
            log.error("Error calling AI service, falling back to basic recommendations: {}", e.getMessage());
        }

        List<User> recommendedUsers;
        
        if (!aiRecommendedUserIds.isEmpty()) {
            // Use AI recommendations
            log.info("Found {} AI recommendations for user {}", aiRecommendedUserIds.size(), currentUser.getId());
            recommendedUsers = userRepository.findAllById(aiRecommendedUserIds);
        } else {
            // Fallback to basic recommendation logic
            log.info("Using fallback recommendation logic for user {}", currentUser.getId());
            recommendedUsers = getBasicRecommendations(currentUser);
        }

        // Convert to DTO and return
        return recommendedUsers.stream()
                .map(this::convertToUserRecommendationDTO)
                .collect(Collectors.toList());
    }

    private List<User> getBasicRecommendations(User currentUser) {
        // Lấy danh sách tất cả người dùng khác (trừ người dùng hiện tại)
        List<User> allUsers = userRepository.findAll().stream()
                .filter(user -> !user.getId().equals(currentUser.getId()))
                .collect(Collectors.toList());

        // Lọc ra những người dùng chưa được swipe
        List<Long> swipedUserIds = swipeRepository.findByInitiatorId(currentUser.getId())
                .stream()
                .map(swipe -> swipe.getTargetUser().getId())
                .collect(Collectors.toList());

        return allUsers.stream()
                .filter(user -> !swipedUserIds.contains(user.getId()))
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
                return handleLikeSwipe(initiator, targetUser, updatedSwipe);
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
        return handleLikeSwipe(initiator, targetUser, savedSwipe);
    }

    private SwipeResponse handleLikeSwipe(User initiator, User targetUser, Swipe swipe) {
        // Kiểm tra xem target user đã like initiator chưa
        Optional<Swipe> targetUserLike = swipeRepository.findLikeByInitiatorAndTargetUser(targetUser.getId(), initiator.getId());

        if (targetUserLike.isPresent()) {
            // Kiểm tra xem đã có match trước đó chưa
            Optional<Match> existingMatch = matchRepository.findByUsers(initiator.getId(), targetUser.getId());
            
            if (existingMatch.isPresent()) {
                // Đã có match trước đó, trả về thông tin match hiện tại
                Match match = existingMatch.get();
                // Lấy hoặc tạo chat room cho match hiện tại
                ChatRoomDTO chatRoom = chatService.createOrGetChatRoom(initiator.getId(), targetUser.getId());
                
                return SwipeResponse.builder()
                        .swipeId(swipe.getId())
                        .isMatch(true)
                        .matchId(match.getId())
                        .chatRoomId(chatRoom.getId())
                        .matchedUserId(targetUser.getId())
                        .matchedUsername(targetUser.getUsername())
                        .matchMessage("You already matched with " + targetUser.getUsername() + "!")
                        .build();
            } else {
                // Chưa có match, tạo match mới
                return createMatch(initiator, targetUser, swipe);
            }
        }

        // Chưa có match, chỉ trả về swipeId và isMatch
        return SwipeResponse.builder()
                .swipeId(swipe.getId())
                .isMatch(false)
                .build();
    }

    private SwipeResponse createMatch(User userA, User userB, Swipe swipe) {
        // Tạo match mới
        Match match = Match.builder()
                .user1(userA)
                .user2(userB)
                .status(Match.MatchStatus.active)
                .build();

        Match savedMatch = matchRepository.save(match);

        // Tạo chat room cho match mới
        ChatRoomDTO chatRoom = chatService.createOrGetChatRoom(userA.getId(), userB.getId());

        String matchMessage = String.format("You and %s have matched! Start chatting now!", userB.getUsername());

        // Gửi thông báo match cho cả hai user
        try {
            notificationService.sendMatchNotification(userA.getId(), savedMatch.getId(), userB.getUsername());
            notificationService.sendMatchNotification(userB.getId(), savedMatch.getId(), userA.getUsername());
            log.info("Sent match notifications to users {} and {}", userA.getId(), userB.getId());
        } catch (Exception e) {
            log.error("Failed to send match notifications: {}", e.getMessage());
        }

        return SwipeResponse.builder()
                .swipeId(swipe.getId())
                .isMatch(true)
                .matchId(savedMatch.getId())
                .chatRoomId(chatRoom.getId())
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

    @Override
    @Transactional(readOnly = true)
    public List<ReceivedLikeDTO> getReceivedLikes(String userEmail) {
        User currentUser = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found", "USER_NOT_FOUND"));

        // Lấy tất cả swipe mà người khác đã like mình nhưng mình chưa phản hồi
        List<Swipe> pendingLikes = swipeRepository.findPendingLikesReceivedByUser(currentUser.getId());

        // Chuyển đổi thành DTO
        return pendingLikes.stream()
                .map(swipe -> convertToReceivedLikeDTO(swipe.getInitiator(), swipe.getCreatedAt()))
                .collect(Collectors.toList());
    }

    private ReceivedLikeDTO convertToReceivedLikeDTO(User user, LocalDateTime likedAt) {
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

        return ReceivedLikeDTO.builder()
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
                .likedAt(likedAt)
                .build();
    }
} 