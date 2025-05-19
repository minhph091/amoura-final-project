package com.amoura.module.profile.domain;

import com.amoura.module.user.domain.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.persistence.*;
import java.io.Serializable;

@Entity
@Table(name = "users_interests")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserInterest {

    @EmbeddedId
    private UserInterestId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("interestId")
    @JoinColumn(name = "interest_id")
    private Interest interest;

    @Embeddable
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserInterestId implements Serializable {

        private static final long serialVersionUID = 1L;

        @Column(name = "user_id")
        private Long userId;

        @Column(name = "interest_id")
        private Long interestId;
    }
}