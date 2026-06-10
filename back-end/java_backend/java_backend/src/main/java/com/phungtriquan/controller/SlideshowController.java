package com.phungtriquan.controller;

import com.phungtriquan.model.Slideshow;
import com.phungtriquan.service.SlideshowService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/slideshows")
@RequiredArgsConstructor
public class SlideshowController {

    private final SlideshowService slideshowService;

    @GetMapping
    public List<Slideshow> getAll() {
        return slideshowService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Slideshow> getById(@PathVariable UUID id) {
        return slideshowService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Slideshow> create(@RequestBody Slideshow slideshow) {
        Slideshow saved = slideshowService.save(slideshow);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Slideshow> update(@PathVariable UUID id, @RequestBody Slideshow slideshow) {
        if (!slideshowService.existsById(id)) return ResponseEntity.notFound().build();
        slideshow.setId(id);
        return ResponseEntity.ok(slideshowService.save(slideshow));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!slideshowService.existsById(id)) return ResponseEntity.notFound().build();
        slideshowService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
