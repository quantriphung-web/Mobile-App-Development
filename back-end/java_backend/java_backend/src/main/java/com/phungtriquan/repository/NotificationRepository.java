package com.phungtriquan.repository;

import com.phungtriquan.model.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {
}
