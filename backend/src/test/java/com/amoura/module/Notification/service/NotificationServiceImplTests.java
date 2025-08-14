package com.amoura.module.Notification.service;

import com.amoura.module.notification.domain.Notification;
import com.amoura.module.notification.repository.NotificationRepository;
import com.amoura.module.notification.service.NotificationServiceImpl;
import io.jsonwebtoken.lang.Assert;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import com.amoura.module.user.domain.User;


@ExtendWith(MockitoExtension.class)
public class NotificationServiceImplTests {
    @Mock
    private NotificationRepository notificationRepository;

    @InjectMocks
    private NotificationServiceImpl notificationService;

    @Test
    @DisplayName(" kiểm tra tb có tồn tại theo id ")
    public void checkIfNotificationExistsById() {
        long notificationId = 1;
        Notification notification = new Notification();
        notification.setId(notificationId);
        Mockito.when(notificationRepository.findById(notificationId)).thenReturn(Optional.of(notification));
        Notification notificationResult = notificationRepository.findById(notificationId).get();
        Assertions.assertEquals(notificationId, notificationResult.getId());

    }


}
