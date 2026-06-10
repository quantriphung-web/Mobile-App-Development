package com.phungtriquan.controller;

import com.phungtriquan.model.Notification;
import com.phungtriquan.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public List<Notification> getAll() {
        return notificationService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Notification> getById(@PathVariable UUID id) {
        return notificationService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Notification> create(@RequestBody Notification notification) {
        Notification saved = notificationService.save(notification);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Notification> update(@PathVariable UUID id, @RequestBody Notification notification) {
        if (!notificationService.existsById(id)) return ResponseEntity.notFound().build();
        notification.setId(id);
        return ResponseEntity.ok(notificationService.save(notification));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!notificationService.existsById(id)) return ResponseEntity.notFound().build();
        notificationService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
