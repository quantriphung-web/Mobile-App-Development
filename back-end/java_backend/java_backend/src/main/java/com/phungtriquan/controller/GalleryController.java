package com.phungtriquan.controller;

import com.phungtriquan.model.Gallery;
import com.phungtriquan.service.GalleryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/gallerys")
@RequiredArgsConstructor
public class GalleryController {

    private final GalleryService galleryService;

    @GetMapping
    public List<Gallery> getAll() {
        return galleryService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Gallery> getById(@PathVariable UUID id) {
        return galleryService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Gallery> create(@RequestBody Gallery gallery) {
        Gallery saved = galleryService.save(gallery);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Gallery> update(@PathVariable UUID id, @RequestBody Gallery gallery) {
        if (!galleryService.existsById(id)) return ResponseEntity.notFound().build();
        gallery.setId(id);
        return ResponseEntity.ok(galleryService.save(gallery));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!galleryService.existsById(id)) return ResponseEntity.notFound().build();
        galleryService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
