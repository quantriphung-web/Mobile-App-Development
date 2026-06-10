package com.phungtriquan.repository;

import com.phungtriquan.model.Gallery;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface GalleryRepository extends JpaRepository<Gallery, UUID> {
}
