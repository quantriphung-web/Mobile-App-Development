package com.phungtriquan.service;

import com.phungtriquan.model.Slideshow;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface SlideshowService {
    List<Slideshow> findAll();
    Optional<Slideshow> findById(UUID id);
    Slideshow save(Slideshow slideshow);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
