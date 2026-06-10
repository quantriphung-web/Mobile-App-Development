package com.phungtriquan.service.impl;

import com.phungtriquan.model.Slideshow;
import com.phungtriquan.repository.SlideshowRepository;
import com.phungtriquan.service.SlideshowService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SlideshowServiceImpl implements SlideshowService {

    private final SlideshowRepository slideshowRepository;
    private final AuditDefaultsService auditDefaultsService;

    @Override
    public List<Slideshow> findAll() {
        return slideshowRepository.findAll();
    }

    @Override
    public Optional<Slideshow> findById(UUID id) {
        return slideshowRepository.findById(id);
    }

 @Override
public Slideshow save(Slideshow slideshow) {
    Instant now = Instant.now();

    if (slideshow.getId() == null) {
        slideshow.setId(UUID.randomUUID());

        UUID defaultStaffAccountId = auditDefaultsService.getDefaultStaffAccountId();

        slideshow.setCreatedAt(now);
        slideshow.setUpdatedAt(now);
        slideshow.setCreatedBy(defaultStaffAccountId);
        slideshow.setUpdatedBy(defaultStaffAccountId);
        slideshow.setClicks(0);

        if (slideshow.getPublished() == null) {
            slideshow.setPublished(true);
        }
    } else {
        slideshow.setUpdatedAt(now);
    }

    return slideshowRepository.save(slideshow);
}

    @Override
    public boolean existsById(UUID id) {
        return slideshowRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        slideshowRepository.deleteById(id);
    }
}
