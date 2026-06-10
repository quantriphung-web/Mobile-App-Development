package com.phungtriquan.service;

import com.phungtriquan.model.Gallery;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface GalleryService {
    List<Gallery> findAll();
    Optional<Gallery> findById(UUID id);
    Gallery save(Gallery gallery);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
