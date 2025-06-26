package com.amoura.module.chat.repository;

import com.amoura.module.chat.domain.UserMessageVisibility;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
 
public interface UserMessageVisibilityRepository extends JpaRepository<UserMessageVisibility, UserMessageVisibility.UserMessageVisibilityId> {
    Optional<UserMessageVisibility> findByUserIdAndMessageId(Long userId, Long messageId);
} 