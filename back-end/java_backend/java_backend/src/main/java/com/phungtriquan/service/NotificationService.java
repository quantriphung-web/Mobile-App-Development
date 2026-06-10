package com.phungtriquan.service;

import com.phungtriquan.model.Notification;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface NotificationService {
    List<Notification> findAll();
    Optional<Notification> findById(UUID id);
    Notification save(Notification notification);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
