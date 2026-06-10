package com.phungtriquan.service.impl;

import com.phungtriquan.model.Gallery;
import com.phungtriquan.repository.GalleryRepository;
import com.phungtriquan.service.GalleryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class GalleryServiceImpl implements GalleryService {

    private final GalleryRepository galleryRepository;
    private final AuditDefaultsService auditDefaultsService;

    @Override
    public List<Gallery> findAll() {
        return galleryRepository.findAll();
    }

    @Override
    public Optional<Gallery> findById(UUID id) {
        return galleryRepository.findById(id);
    }

    @Override
    public Gallery save(Gallery gallery) {
        Instant now = Instant.now();
        if (gallery.getId() == null) {
            UUID defaultStaffAccountId = auditDefaultsService.getDefaultStaffAccountId();
            if (gallery.getCreatedAt() == null) {
                gallery.setCreatedAt(now);
            }
            if (gallery.getCreatedBy() == null) {
                gallery.setCreatedBy(defaultStaffAccountId);
            }
            if (gallery.getUpdatedBy() == null) {
                gallery.setUpdatedBy(defaultStaffAccountId);
            }
        }
        gallery.setUpdatedAt(now);
        return galleryRepository.save(gallery);
    }

    @Override
    public boolean existsById(UUID id) {
        return galleryRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        galleryRepository.deleteById(id);
    }
}
