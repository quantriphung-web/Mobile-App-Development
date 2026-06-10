package com.phungtriquan.controller;

import com.phungtriquan.model.CardItem;
import com.phungtriquan.service.CardItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/card-items")
@RequiredArgsConstructor
public class CardItemController {

    private final CardItemService cardItemService;

    @GetMapping
    public List<CardItem> getAll() {
        return cardItemService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<CardItem> getById(@PathVariable UUID id) {
        return cardItemService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<CardItem> create(@RequestBody CardItem cardItem) {
        CardItem saved = cardItemService.save(cardItem);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<CardItem> update(@PathVariable UUID id, @RequestBody CardItem cardItem) {
        if (!cardItemService.existsById(id)) return ResponseEntity.notFound().build();
        cardItem.setId(id);
        return ResponseEntity.ok(cardItemService.save(cardItem));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!cardItemService.existsById(id)) return ResponseEntity.notFound().build();
        cardItemService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
