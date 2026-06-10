package com.phungtriquan.repository;

import com.phungtriquan.model.Slideshow;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface SlideshowRepository extends JpaRepository<Slideshow, UUID> {
}
