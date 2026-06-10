package com.phungtriquan.service.impl;

import com.phungtriquan.model.Notification;
import com.phungtriquan.repository.NotificationRepository;
import com.phungtriquan.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final NotificationRepository notificationRepository;

    @Override
    public List<Notification> findAll() {
        return notificationRepository.findAll();
    }

    @Override
    public Optional<Notification> findById(UUID id) {
        return notificationRepository.findById(id);
    }

    @Override
    public Notification save(Notification notification) {
        if (notification.getCreatedAt() == null) {
            notification.setCreatedAt(Instant.now());
        }
        return notificationRepository.save(notification);
    }

    @Override
    public boolean existsById(UUID id) {
        return notificationRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        notificationRepository.deleteById(id);
    }
}
